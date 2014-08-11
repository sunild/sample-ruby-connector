# This class implements functionality that handles a stream input and
# should be implemented to suit your own needs. In this sample app,
# it merely places the stream contents into a redis queue for processing
# by other actors

require 'mongo'
require 'json'

module ThinConnector
  module Processor

    class MongoStreamProcessor
      include ThinConnector::Processor::StreamDelegate
      attr_accessor :stream
      MONGO_COLLECTION = 'tweets'

      def initialize(the_stream)
        @logger = ThinConnector::Logger.new
        @stream = the_stream
        @logger.debug "attaching to Mongo with configs #{ThinConnector::Environment.instance.mongo_config}"
      end

      def start
        stream.start do |obj|
          begin
            self.put_in_mongo obj
          rescue Exception => e
            @logger.error "Error putting into Mongo: #{e}"
          end
        end
      end

      def put_in_mongo(obj)
        mongo_collection.insert obj
      end

      private
      def mongo_collection
        @collection ||= mongo_db.collection MONGO_COLLECTION
      end

      def mongo_db; mongo_client.db ThinConnector::Environment.instance.mongo_config[:database]; end

      def mongo_client
        config = ThinConnector::Environment.instance.mongo_config
        @_mongo_client ||= Mongo::MongoClient.new config[:host], config[:port]
      end

    end
  end
end
