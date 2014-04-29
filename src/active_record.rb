require 'active_record'

config_path = File.join( ThinConnector::Environment.instance.root, 'config', 'database.yml')
configuration = YAML.load(config_path)[ThinConnector::Environment.instance.env.to_sym]

ActiveRecord::Base.establish_connection configuration
ActiveRecord::Base.logger = ThinConnector::Logger.new