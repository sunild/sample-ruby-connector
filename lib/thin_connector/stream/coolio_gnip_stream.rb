require 'cool.io'
require 'logger'

module ThinConnector
  module Stream
    class CoolioGNIPStream < Coolio::HttpClient

      @reconnect_wait_time=0
      @logger = Object::Logger.new(STDOUT)
      @logger.level = Object::Logger::DEBUG

      # Move into Environment!!!!
      @url = 'https://stream.gnip.com:443/accounts/isaacs/publishers/twitter/streams/track/prod.json'

      def initialize
        super( { fork_check: true } )
      end

      def start
        @logger.info = "No block passed, printing to STDOUT" unless block

        if block_given?
          @block = Proc.new
        else
          @block = Proc.new do |data|
            puts data.to_s
          end
        end

        connect_stream
      end

      def stop
        @stopped = true
        _stop
      end

      def on_connect
        super
        @logger.info "Connected to #{url}"
      end

      def on_connect_failed
        super
        reconnect
      end

      def on_response_header(header)
        @logger.info "Response: #{header.http_version} #{header.status} #{header.http_reason}"
      end

      def on_body_data(data); perform_on_chunk data; end

      def on_request_complete
        @logger.info "End of stream reached, attempting to reconnect"
        reconnect
      end

      def on_error(reason)
        logger.warn "Error in stream: #{reason}"
        reconnect
      end


      protected

      def _stop
        @run_loop.stop
        @client = @run_loop = nil
      end

      def connect_stream
        @run_loop = Coolio::Loop.default
        @client = self.connect_stream(url, 80, headers).attach @run_loop
        @client.request('GET', '', :query => { :q => 'foobar' })
        @run_loop.run
      end

      def stream_running?
        @stopped
      end

      # Make a reconnect attempt and increase sleep time if failed
      def reconnect
        logger.warn "Attempting to reconnecto to the stream"
        sleep @reconnect_wait_time
        @run_loop = @client = nil
        connect_stream
        bump_reconnect_time
      end

      def bump_reconnect_time
        @reconnect_wait_time = @reconnect_wait_time * 2
        raise "Max reconnect time exceeded" if Stream.max_reconnect_time > @reconnect_wait_time
      end

      def reset_reconnect_time; @reconnect_wait_time=0; end

      def perform_on_chunk(chunk)
        @block.call chunk
      end
    end
  end
end