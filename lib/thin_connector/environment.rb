require 'singleton'
require 'yaml'

module ThinConnector
  class Environment
    include Singleton

    REDIS_NAMESPACE = 'thinconnector'
    attr_reader :gnip_username, :gnip_password, :root, :redis_config, :env

    load_project_configuration

    def env=(set_env)
      if env
        raise 'Env already set, cannot change mid execution'
      else
        @env = set_env
      end
    end

    private

    def configuration_file_path
      File.join File.expand_path( File.dirname(__FILE__) ), '..', '..', 'config', 'application.yml'
    end

    def redis_configuration_file_path
      File.join File.expand_path( File.dirname(__FILE__) ), '..', '..', 'config', 'redis.yml'
    end

    def load_project_configuration
      config = YAML.load_file configuration_file_path
      @gnip_username = config['gnip_username']
      @gnip_password = config['gnip_password']
      @root = File.join File.expand_path(File.dirname __FILE__ ), '..', '..'
    end

    def load_redis_configuration

    end
  end
end