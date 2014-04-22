# This class implements functionality that handles a stream input and
# should be implemented to suit your own needs. In this sample app,
# it merely places the stream contents into a redis queue for processing
# by other actors

require 'redis'

module ThinConnector
  module Processor

    class RedisStreamProcessor
      include StreamDelegate

      REDIS_NAMESPACE = "stream_processor:raw"
      attr_accessor :stream

      def initialize(the_stream)
        @stream = the_stream
      end

      def start
        stream.start do |object|
          put_in_redis object
        end
      end

      def stop
        stream.stop
      end

      private

      def put_in_redis(obj)
        redis_client.lpush redis_queue, obj
      end

      def redis_queue; Environment.instance.redis_namespace + ":#{REDIS_NAMESPACE}"; end

      def redis_client
        @_redis_client ||= Redis.new ThinConnector::Environment.instance.redis_config
        @_redis_client
      end

    end
  end
end
