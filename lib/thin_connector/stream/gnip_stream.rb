require 'eventmachine'
require 'em-http-request'

module ThinConnector
  module Stream

    class GNIPStream < Stream::Base

      EventMachine.threadpool_size = 3

      attr_accessor :headers, :options, :url, :username, :password

      def initialize(url, headers={})
        @url = url
        @headers = headers
      end

      def start(&process_block)

      end

      def stop

      end

      def on_message(&block)
        @on_message = block
      end

      def on_connection_close(&block)
        @on_connection_close = block
      end

      def on_error(&block)
        @on_error = block
      end

      private

      def connect
        EM.run do
          http = EM::HttpRequest.new(@url, :inactivity_timeout => 2**16, :connection_timeout => 2**16).get(:head => @headers)
          http.stream { |chunk| process_chunk(chunk) }
          http.callback {
            handle_connection_close(http)
            EM.stop
          }
          http.errback {
            handle_error(http)
            EM.stop
          }
        end
      end

      def process_chunk(chunk)
        @prcessor.call chunk
        @processor.complete_entries.each do |entry|
          EM.defer { @on_message.call entry }
        end
      end

      def handle_error(http_connection)
        @on_error.call(http_connection)
      end

      def handle_connection_close(http_connection)
        @on_connection_close.call(http_connection)
      end

    end

  end
end
