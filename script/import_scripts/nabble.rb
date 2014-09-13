require File.expand_path(File.dirname(__FILE__) + "/base.rb")

require 'pg'

class ImportScripts::Nabble < ImportScripts::Base

  NABBLE_DB   = "nabble"
  BATCH_SIZE = 1000

  ORIGINAL_SITE_PREFIX = "oldsite.example.com/forums" # without http(s)://
  NEW_SITE_PREFIX      = "http://discourse.example.com"  # with http:// or https://

  def initialize
    super

    @client = PG.connect( dbname: NABBLE_DB )
  end

  def execute
    import_users
    #import_categories
    import_posts
    #import_private_messages
    #suspend_users
  end

  def import_users
    puts '', "creating users"

    total_count = @client.exec("SELECT count(*) count
                                FROM user_ u").field_values('count')[0]

    puts '', "#{total_count} users found"

    
    batches(BATCH_SIZE) do |offset|
      results = @client.exec(
        "SELECT user_id id, email, name, joined
           FROM user_ u
          ORDER BY u.user_id ASC
          LIMIT #{BATCH_SIZE}
         OFFSET #{offset};")

      break if results.ntuples < 1

      create_users(results, total: total_count, offset: offset) do |user|
        { id: user['id'],
          email: user['email'],
          username: user['name'],
          created_at: user['joined'],
          moderator: false,
          admin: false }
      end
    end
  end

  def import_categories
    results = mysql_query("
      SELECT forum_id id, parent_id, left(forum_name, 50) name, forum_desc description
        FROM phpbb_forums
    ORDER BY parent_id ASC, forum_id ASC
    ")

    create_categories(results) do |row|
      h = {id: row['id'], name: CGI.unescapeHTML(row['name']), description: CGI.unescapeHTML(row['description'])}
      if row['parent_id'].to_i > 0
        parent = category_from_imported_category_id(row['parent_id'])
        h[:parent_category_id] = parent.id if parent
      end
      h
    end
  end

  def import_posts
    puts "", "creating topics and posts"

    total_count = @client.exec("SELECT count(*) count from node WHERE parent_id is not null").field_values("count")[0]
    
    root_node_id = @client.exec("SELECT node_id id from node WHERE parent_id is null").field_values("id")[0]

    puts '', "#{total_count} topics and posts found"

    batches(BATCH_SIZE) do |offset|
      results = @client.exec("
        SELECT n.node_id id,
               n.parent_id topic_id,
               n.subject title,
               n.owner_id user_id,
               m.message raw,
               n.when_created post_time
          FROM node n,
               node_msg m
         WHERE n.node_id = m.node_id
           AND n.parent_id is not null
           AND n.node_id < 20
      ORDER BY id
         LIMIT #{BATCH_SIZE}
        OFFSET #{offset};
      ")

      break if results.ntuples < 1

      create_posts(results, total: total_count, offset: offset) do |m|
        mapped = {}

        mapped[:id] = m['id']
        mapped[:user_id] = user_id_from_imported_user_id(m['user_id']) || -1
        mapped[:raw] = process_nabble_post(m['raw'])
        mapped[:created_at] = m['post_time']

        if m['topic_id'] == root_node_id
          mapped[:title] = CGI.unescapeHTML(m['title'])
        else
          mapped[:topic_id] = m[:topic_id]
        end

        mapped
      end
    end
  end

  def import_private_messages
    puts "", "creating private messages"

    total_count = mysql_query("SELECT count(*) count from phpbb_privmsgs").first["count"]

    batches(BATCH_SIZE) do |offset|
      results = mysql_query("
        SELECT msg_id id,
               root_level,
               author_id user_id,
               message_time,
               message_subject,
               message_text
          FROM phpbb_privmsgs
      ORDER BY root_level ASC, msg_id ASC
         LIMIT #{BATCH_SIZE}
        OFFSET #{offset};
      ")

      break if results.size < 1

      create_posts(results, total: total_count, offset: offset) do |m|
        skip = false
        mapped = {}

        mapped[:id] = "pm:#{m['id']}"
        mapped[:user_id] = user_id_from_imported_user_id(m['user_id']) || -1
        mapped[:raw] = process_phpbb_post(m['message_text'], m['id'])
        mapped[:created_at] = Time.zone.at(m['message_time'])

        if m['root_level'] == 0
          mapped[:title] = CGI.unescapeHTML(m['message_subject'])
          mapped[:archetype] = Archetype.private_message

          # Find the users who are part of this private message.
          # Found from the to_address of phpbb_privmsgs, by looking at
          # all the rows with the same root_level.
          # to_address looks like this: "u_91:u_1234:u_200"
          # The "u_" prefix is discarded and the rest is a user_id.

          import_user_ids = mysql_query("
            SELECT to_address
              FROM phpbb_privmsgs
             WHERE msg_id = #{m['id']}
                OR root_level = #{m['id']}").map { |r| r['to_address'].split(':') }.flatten!.map! { |u| u[2..-1] }

          mapped[:target_usernames] = import_user_ids.map! do |import_user_id|
            import_user_id.to_s == m['user_id'].to_s ? nil : User.find_by_id(user_id_from_imported_user_id(import_user_id)).try(:username)
          end.compact.uniq

          skip = true if mapped[:target_usernames].empty? # pm with yourself?
        else
          parent = topic_lookup_from_imported_post_id("pm:#{m['root_level']}")
          if parent
            mapped[:topic_id] = parent[:topic_id]
          else
            puts "Parent post pm:#{m['root_level']} doesn't exist. Skipping #{m["id"]}: #{m["message_subject"][0..40]}"
            skip = true
          end
        end

        skip ? nil : mapped
      end
    end
  end

  def suspend_users
    puts '', "updating banned users"

    where = "ban_userid > 0 AND (ban_end = 0 OR ban_end > #{Time.zone.now.to_i})"

    banned = 0
    failed = 0
    total = mysql_query("SELECT count(*) count FROM phpbb_banlist WHERE #{where}").first['count']

    system_user = Discourse.system_user

    mysql_query("SELECT ban_userid, ban_start, ban_end, ban_give_reason FROM phpbb_banlist WHERE #{where}").each do |b|
      user = find_user_by_import_id(b['ban_userid'])
      if user
        user.suspended_at = Time.zone.at(b['ban_start'])
        user.suspended_till = b['ban_end'] > 0 ? Time.zone.at(b['ban_end']) : 200.years.from_now

        if user.save
          StaffActionLogger.new(system_user).log_user_suspend(user, b['ban_give_reason'])
          banned += 1
        else
          puts "Failed to suspend user #{user.username}. #{user.errors.try(:full_messages).try(:inspect)}"
          failed += 1
        end
      else
        puts "Not found: #{b['ban_userid']}"
        failed += 1
      end

      print_status banned + failed, total
    end
  end

  def process_nabble_post(raw)
    s = raw.dup

    match = s.match(/boundary="?([^\r|"]*)/i)
    if match
      boundary = match.captures[0]
 
      puts '', "match #{boundary}"
      index = s.index(/^--#{boundary}/)

      puts "index #{index}"
      puts "s.length #{s.length}"
      s = s[index..s.length]
      s.gsub!(/^--#{boundary}/, '')
      s.gsub!(/^Content-(.*):(.*)/, '')

      puts '', "raw #{s}"
    end
    s = CGI.unescapeHTML(s)
    s
  end

  def process_phpbb_post(raw, import_id)
    s = raw.dup

    # :) is encoded as <!-- s:) --><img src="{SMILIES_PATH}/icon_e_smile.gif" alt=":)" title="Smile" /><!-- s:) -->
    s.gsub!(/<!-- s(\S+) -->(?:.*)<!-- s(?:\S+) -->/, '\1')

    # Internal forum links of this form: <!-- l --><a class="postlink-local" href="https://example.com/forums/viewtopic.php?f=26&amp;t=3412">viewtopic.php?f=26&amp;t=3412</a><!-- l -->
    s.gsub!(/<!-- l --><a(?:.+)href="(?:\S+)"(?:.*)>viewtopic(?:.*)t=(\d+)<\/a><!-- l -->/) do |phpbb_link|
      replace_internal_link(phpbb_link, $1, import_id)
    end

    # Some links look like this: <!-- m --><a class="postlink" href="http://www.onegameamonth.com">http://www.onegameamonth.com</a><!-- m -->
    s.gsub!(/<!-- \w --><a(?:.+)href="(\S+)"(?:.*)>(.+)<\/a><!-- \w -->/, '[\2](\1)')

    # Many phpbb bbcode tags have a hash attached to them. Examples:
    #   [url=https&#58;//google&#46;com:1qh1i7ky]click here[/url:1qh1i7ky]
    #   [quote=&quot;cybereality&quot;:b0wtlzex]Some text.[/quote:b0wtlzex]
    s.gsub!(/:(?:\w{8})\]/, ']')

    s = CGI.unescapeHTML(s)

    # phpBB shortens link text like this, which breaks our markdown processing:
    #   [http://answers.yahoo.com/question/index ... 223AAkkPli](http://answers.yahoo.com/question/index?qid=20070920134223AAkkPli)
    #
    # Work around it for now:
    s.gsub!(/\[http(s)?:\/\/(www\.)?/, '[')

    # Replace internal forum links that aren't in the <!-- l --> format
    s.gsub!(internal_url_regexp) do |phpbb_link|
      replace_internal_link(phpbb_link, $1, import_id)
    end

    s
  end

  def replace_internal_link(phpbb_link, import_topic_id, from_import_post_id)
    results = mysql_query("select topic_first_post_id from phpbb_topics where topic_id = #{import_topic_id}")

    return phpbb_link unless results.size > 0

    linked_topic_id = results.first['topic_first_post_id']
    lookup = topic_lookup_from_imported_post_id(linked_topic_id)

    return phpbb_link unless lookup

    t = Topic.find_by_id(lookup[:topic_id])
    if t
      "#{NEW_SITE_PREFIX}/t/#{t.slug}/#{t.id}"
    else
      phpbb_link
    end
  end

  def internal_url_regexp
    @internal_url_regexp ||= Regexp.new("http(?:s)?://#{ORIGINAL_SITE_PREFIX.gsub('.', '\.')}/viewtopic\\.php?(?:\\S*)t=(\\d+)")
  end

  def mysql_query(sql)
    @client.query(sql, cache_rows: false)
  end
end

ImportScripts::Nabble.new.perform
