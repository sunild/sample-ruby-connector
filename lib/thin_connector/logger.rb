require 'logger'
require 'forwardable'

module ThinConnector

  class Logger
    include Forwardable

    LOG_LEVELS = {
        [:unknown, 0] => Object::Logger::UNKNOWN,
        [:fatal,   1] => Object::Logger::FATAL,
        [:error,   2] => Object::Logger::ERROR,
        [:warn,    3] => Object::Logger::WARN,
        [:info,    4] => Object::Logger::INFO,
        [:debug,   5] => Object::Logger::DEBUG
    }
    DEVELOPMENT = 'development'

    # Forward on specified log methods to logger instance
    def_delegators :@logger_instance, :debug, :info, :warn, :error, :fatal, :unknown

    def initialize
      @logger_instance = logger_instance
    end

    def method_missing(method, *args, &block)
      if log_levels.include? method.to_sym and should_log?(method.to_sym)
        logger_instance.send method, args, block
      end

      super
    end

    private

    def logger_instance
      instance = Object::Logger.new(log_file_path)
      log_level = get_log_level
      puts "Set log level to #{log_level}"
      instance.level = log_level
      instance
    end

    def log_levels
      LOG_LEVELS
    end

    def get_log_level
      env_log_level = ThinConnector::Environment.instance.log_level

      if [String, Symbol].include? env_log_level.class
        log_levels.detect{ |level_arr, level| level_arr.first == env_log_level.to_sym }.to_a.flatten.first
      elsif env_log_level.is_a? Numeric
        log_levels.detect{ |level_arr, level| level_arr.last == env_log_level }.to_a.flatten.first
      else
        raise "Invalid log level #{env_log_level}"
      end
    end


    def log_file_path
      log_file_name = "#{(ThinConnector::Environment.instance.env || DEVELOPMENT)}.log"
      File.join ThinConnector::Environment.instance.root, 'log', log_file_name
    end

  end
end