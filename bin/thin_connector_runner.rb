require 'yaml'
require_relative '../src/thin_connector.rb'

##################
# Helpers
##################

def repl
  loop do
    print '> '
    cmd = gets
    handle_command cmd
  end
end

def handle_command(cmd)
  strip_cmd = (cmd.downcase.gsub /\W/, '').to_sym
  block = commands[strip_cmd]
  block.call if block
end

def commands
  {
      redis: Proc.new{ redis_processor },
      stdout: Proc.new{ print_stream_processor },
      mongo: Proc.new{ mongo_processor },
      configure: Proc.new{ configure },
      exit: Proc.new{ repl_exit },
      help: Proc.new{ puts help_msg }
  }
end

def help_msg
  <<-eos
    Welcome to the Ruby Thin Connector!
    This is a sample application that demonstrates best practices when
    consuming the Gnip set of streaming APIs

    Commands:

    configure # Run the interactive configuration
    redis # Run the redis
    stdout # Run the stdout processor
  eos
end

def repl_exit
  puts 'See you next time! :)'
  exit 0
end

def configure
  config = {}
  loop do
    print 'Enter gnip username: '
    config[:gnip_username] = gets
    break unless config[:gnip_username].empty?
    puts 'Username cannot be empty!'
  end

  loop do
    print 'Enter gnip password: '
    config[:gnip_password] = gets
    break unless config[:gnip_password].empty?
    puts 'cannot be empty!'
  end

  loop do
    print 'Enter gnip url: '
    config[:gnip_url] = gets
    break unless config[:gnip_url].empty?
    puts 'cannot be empty!'
  end

  print 'Enter debug level (fatal, error, info, debug): '
  level = gets
  config[:log_level] = level || 'debug'

  env_config = {
      test: config,
      development: config,
      production: config,
      staging: config
  }
  write_out_config env_config
  puts "Configuration: #{config.to_yaml}"
end

def write_out_config(config)
  file = File.join File.dirname(__FILE__), '..', 'config', 'application.yml'
  File.open(file, 'w+') do |f|
    f.truncate 0
    f << config.to_yaml
  end
end

def mongo_processor
  stream = setup_stream
  mongo_processor = ThinConnector::Processor::MongoStreamProcessor.new stream
  run_processor mongo_processor
  puts <<-eos
    Mongo processor finished! Go check the
    Mongo server 'tweets' collection to see what we brought in!
  eos
end

def redis_processor
  stream = setup_stream
  redis_processor = ThinConnector::Processor::RedisStreamProcessor.new stream
  redis = Redis.new ThinConnector::Environment.instance.redis_config
  redis.flushall

  run_processor(redis_processor)

  puts <<-eos
Redis processor stopped. Head over to the redis-cli to see what we got!


hint, run:
> redis-cli
> KEYS *    # Command to show all keys
> llen
  eos
end

def run_processor(processor)
  processing_thread = Thread.new do
    processor.start
  end

  puts "#{processor.class.to_s} processor started. Press ENTER to stop\n\n"

  while true
    break if "\n"==gets
  end
  print 'Stopping'
  stop_thread = Thread.new do
    processor.stop
    processing_thread.join
  end

  while stop_thread.alive?
    print '.'
    sleep 1
  end
end

def print_stream_processor

end

def setup_stream
  environment = ThinConnector::Environment.instance
  url = 'https://stream.gnip.com:443/accounts/isaacs/publishers/twitter/streams/track/prod.json'
  headers = {
      authorization: [environment.gnip_username, environment.gnip_password],
      'Accept-Encoding' => 'gzip,deflate,sdch'
  }
  ThinConnector::Stream::GNIPStream.new url, headers
end

##################
# End helpers
##################

puts help_msg
repl