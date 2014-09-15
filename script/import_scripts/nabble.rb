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
    import_posts
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
      ORDER BY id
         LIMIT #{BATCH_SIZE}
        OFFSET #{offset};
      ")

      break if results.ntuples < 1

      create_posts(results, total: total_count, offset: offset) do |m|
        skip = false
        mapped = {}

        mapped[:id] = m['id']
        mapped[:user_id] = user_id_from_imported_user_id(m['user_id']) || -1
        mapped[:raw] = process_nabble_post(m['raw'])
        mapped[:created_at] = m['post_time']

        if m['topic_id'] == root_node_id
          mapped[:title] = CGI.unescapeHTML(m['title'])
        else
          parent = topic_lookup_from_imported_post_id(m['topic_id'])
          if parent
            mapped[:topic_id] = parent[:topic_id]
          else
            puts "Parent post #{m['topic_id']} doesn't exist. Skipping #{m["id"]}: #{m["title"][0..40]}"
            skip = true
          end
        end

        skip ? nil : mapped

      end
    end
  end

  def process_nabble_post(raw)
    s = raw.dup
    # Strange encoding characters
    s.gsub!(/=20/, '')
    # Removes truncated lines
    s.gsub!(/=[\n\r]/, '')
    boundaries_found = s.match(/boundary="?([^\n|\r|"]*)/i)
    if boundaries_found
      boundary = boundaries_found.captures[0]
      # The first block surrounded boundary tags is in plain/text
      boundary_regexp = /#{Regexp.escape('--' + boundary)}[\n\r]+(.*)#{Regexp.escape('--' + boundary)}[\n\r]+/im
      email_text_plain_found = s.match(boundary_regexp)
      if email_text_plain_found
        s = email_text_plain_found.captures[0]
      end
      s.gsub!(/^Content-.*:.*[\n\r]?.*\n/i, '')
    end
    # Removes Nabble mailing list email
    s.gsub!(/(^On .*,.*)(<.*@.*nabble\.com>) (wrote:)/mi, "\\1\\3")
    s.gsub!(/(On .*,.*)(<\[hidden email\].*>) (wrote:)/mi, "\\1\\3")
    # Keeps quoted text on one line
    s.gsub!(/(^>.*)=[\n\r]+(.*)/i, '\1\2')
    # Removes Nabble email footer to reply
    s.gsub!(/^>+ ------------------------------.*naml>[\n\r]+([\n\r]+>[\n\r]+)?/m, '')
    s.gsub!(/^>+ If you reply to this email,.*NAML.*(<http:\/\/discuss\.asciidoctor\.org\/.*>)?/m, '')
    s = CGI.unescapeHTML(s)
    s
  end
end

ImportScripts::Nabble.new.perform
