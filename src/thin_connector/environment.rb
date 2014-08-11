require 'yaml'

module ThinConnector
  class Environment

    REDIS_NAMESPACE = 'thinconnector'
    DEFAULT_ENV = 'development'
    DEFAULT_LOG_LEVEL = :debug

    attr_reader :gnip_username, :gnip_password, :gnip_url, :root, :redis_config, :log_level, :redis_namespace
    @@_singleton__instance = nil
    @@_singleton_mutex = Mutex.new

    def self.instance
      return @@_singleton__instance if @@_singleton__instance
      @@_singleton_mutex.synchronize {
        return @@_singleton__instance if @@_singleton__instance
        @@_singleton__instance = new
      }
      @@_singleton__instance
    end

    def env
      unless @env
        @env = ENV['THIN_CONNECTOR_ENV']
      end
      @env || DEFAULT_ENV
    end

    private

    def load_project_configuration
      config = YAML.load_file(configuration_file_path)[env.to_sym]

      # https://stream.gnip.com:443/accounts/isaacs/publishers/twitter/streams/track/prod.json
      @gnip_username     = config[:gnip_username].strip
      @gnip_password     = config[:gnip_password].strip
      @gnip_url          = config[:gnip_url].strip
      @root              = File.join File.expand_path(File.dirname __FILE__ ), '..', '..'
      @log_level         = config[:log_level].strip || DEFAULT_LOG_LEVEL
      @gnip_account_name = extract_account_name_from_uri gnip_url
      @gnip_stream_label = extract_stream_label_from_uri gnip_url
      load_redis_configuration
    end

    def initialize
      load_project_configuration
    end

    def configuration_file_path
      File.join File.expand_path( File.dirname(__FILE__) ), '..', '..', 'config', 'application.yml'
    end

    def redis_configuration_file_path
      File.join File.expand_path( File.dirname(__FILE__) ), '..', '..', 'config', 'redis.yml'
    end

    def load_redis_configuration
      @redis_namespace = ThinConnector::Environment::REDIS_NAMESPACE
      @redis_config = YAML.load_file(redis_configuration_file_path).symbolize_keys[env.to_sym]
    end

    def extract_account_name_from_uri(uri)
      uri.match( /accounts\/[^\/]+/ )[0].split('/').last
    end

    def extract_stream_label_from_uri(uri)
      uri.match( /[^\/]+\.json/ )[0].gsub '.json', ''
    end

  end
end