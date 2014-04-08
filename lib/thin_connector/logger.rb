require 'forwardable'
require 'logger'
module ThinConnector

  class Logger
    include Forwardable


    def initialize

    end

    def log(str)
      logger_instance
    end

    def method_missing(method, *args, &block)
      super
    end

    private

    def logger_instance
      nil
    end

    def log_levels
      %w(
        info
        debug
        warn
        error
        fatal
      )
    end
  end

end