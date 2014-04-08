require 'singleton'
require 'yaml'

module ThinConnector
  class Environment
    include Singleton
    attr_accessor :gnip_username, :gnip_password, :root, :redis_namespace
    load_project_configuration

    private

    def configuration_file_path
      File.join File.expand_path( File.dirname(__FILE__) ), '..', '..', 'config.yml'
    end

    def load_project_configuration
      config = YAML.load_file configuration_file_path
      gnip_username = config['gnip_username']
      gnip_password = config['gnip_password']
      root = File.join File.expand_path(File.dirname __FILE__ ), '..', '..'
      redis_namespace = 'thinconnector'
    end
  end
end