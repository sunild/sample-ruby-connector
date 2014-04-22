require 'eventmachine'
require 'em-http-request'
require 'json'
require_relative './stream_helper.rb'

module ThinConnector
  module Stream

    class GNIPStream < Stream::Base
      include ThinConnector::Stream::StreamHelper

      EventMachine.threadpool_size = 3

      attr_accessor :headers, :options, :url
      attr_reader :username, :password

      def initialize(url=nil, headers={})
        @logger = ThinConnector::Logger.new
        @url = url

        # testing
        @url ||= 'https://stream.gnip.com:443/accounts/isaacs/publishers/twitter/streams/track/prod.json'
        @headers = headers.merge({ accept: 'application/json'})
        @stream_reconnect_time = 1
      end

      def start
        if block_given?
          @processor = Proc.new
        else
          @processor = Proc.new{ |data| puts data }
        end
        connect_stream
      end

      def stop
        EventMachine.stop
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

      def connect_stream
        EM.run do
          return if stopped?
          http = EM::HttpRequest.new(@url, keep_alive: true,  inactivity_timeout: 2**16, connection_timeout: 100000).get(head: @headers)
          http.stream { |chunk| process_chunk(chunk) }
          http.callback {
            handle_connection_close(http)
            reconnect
          }
          http.errback {
            handle_error(http)
            reconnect
          }

        end
      end

      def reconnect
        return if stopped?
        sleep @stream_reconnect_time
        bump_reconnect_time
        reset_reconnect_time if connect_stream
      end

      def process_chunk(chunk)
        @logger.debug "\n\nprocess_chunk_called #{chunk}\n\n"
        @processor.call chunk
      end

      def handle_error(http_connection)
        @logger.error("Error with http connection " + http_connection.inspect)
      end

      def handle_connection_close(http_connection)
        @logger.warn "HTTP connection closed #{http_connection.inspect}"
        reconnect
      end

      def stopped?
        @stopped
      end

      def username=(username)
        @username = username
        @headers.merge!({ username: username })
      end

      def password=(pw)
        @password = pw
        @headers.merge!({ password: pw })
      end

    end
  end
end
