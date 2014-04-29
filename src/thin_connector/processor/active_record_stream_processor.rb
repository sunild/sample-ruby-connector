module ThinConnector
  module Processor

    class ActiveRecordStreamProcessor

      include ThinConnector::Processor::StreamDelegate
      attr_accessor :stream

      def initialize(the_stream)
        @stream = the_stream
      end

      def start
        stream.start{ |object| create_and_save_in_db object }
      end

      private

      def create_and_save_in_db(payload)
        t = ThinConnector::Models::Tweet.new payload
        t.save
      end

    end

  end
end