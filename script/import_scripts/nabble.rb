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
end

ImportScripts::Nabble.new.perform
