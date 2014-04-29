# require 'active_record'
#
# config_path = File.expand_path File.join( ThinConnector::Environment.instance.root, 'config', 'database.yml')
# configuration = YAML.load_file(config_path)[ThinConnector::Environment.instance.env.to_sym]
# debugger
# ActiveRecord::Base.establish_connection configuration
# ActiveRecord::Base.logger = ThinConnector::Logger.new