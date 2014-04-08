require 'yaml'

module ThinConnector
  class Environment

    REDIS_NAMESPACE = 'thinconnector'
    DEFAULT_ENV = 'development'

    attr_reader :gnip_username, :gnip_password, :root, :redis_config, :log_level, :redis_namespace
    @@_singleton__instance = nil
    @@_singleton_mutex = Mutex.new

    def self.instance
      return @@_singleton__instance if @@_singleton__instance
      @@_singleton_mutex.synchronize {
        return @@_singleton__instance if @@_singleton__instance
        @@_singleton__instance = new
        @@_singleton__instance.load_project_configuration
      }
      @@_singleton__instance
    end


    def env=(set_env)
      if env
        raise 'Env already set, cannot change mid execution'
      else
        @env = set_env
      end
    end

    def env
      @env || DEFAULT_ENV
    end

    def load_project_configuration
      config = YAML.load_file(configuration_file_path)[env]

      @gnip_username = config['gnip_username']
      @gnip_password = config['gnip_password']
      @gnip_url      = config['gnip_url']
      @root          = File.join File.expand_path(File.dirname __FILE__ ), '..', '..'
      @log_level     = config['log_level']
      @redis_namespace = REDIS_NAMESPACE
      load_redis_configuration
    end

    private

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
       @redis_config = YAML.load_file(redis_configuration_file_path).symbolize_keys[env.to_sym]
    end

  end
end