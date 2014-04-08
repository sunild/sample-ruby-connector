# This class implements functionality that handles a stream input and
# should be implemented to suit your own needs. In this sample app,
# it merely places the stream contents into a redis queue for processing
# by other actors

module ThinConector
  class StreamProcessor

    REDIS_NAMESPACE = "stream_processor:raw"

    def initialize(stream)

    end

    private

    def put_in_redis(obj)

    end

    def redis_queue; Environment.instance.redis_namespace + ":#{REDIS_NAMESPACE}"; end

    def stream; @stream; end

    def stream=(stream); @stream = stream; end
  end
end