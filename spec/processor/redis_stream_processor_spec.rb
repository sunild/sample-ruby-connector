require_relative '../spec_helper'

describe ThinConnector::Processor::RedisStreamProcessor do

  let!(:environment)    { ThinConnector::Environment.instance }
  let!(:url)            { 'https://stream.gnip.com:443/accounts/isaacs/publishers/twitter/streams/track/prod.json' }
  let!(:headers)        {
                          {
                            authorization: [environment.gnip_username, environment.gnip_password],
                            'Accept-Encoding' => 'gzip,deflate,sdch'
                          }
                        }

  let!(:stream)         { ThinConnector::Stream::GNIPStream.new(url, headers) }
  let(:redis_processor) { ThinConnector::Processor::RedisStreamProcessor.new stream }
  let(:redis)           { Redis.new ThinConnector::Environment.instance.redis_config }
  let(:redis_queue)     { ThinConnector::Environment.instance.redis_namespace + ":stream_processor:raw" }

  it 'should put the paylaods into the appropriate Redis list' do
    redis.flushall
    processing_thread = Thread.new do
      redis_processor.start
    end
    redis_processor.stop
    processing_thread.join

    number_of_payloads = redis.llen redis_queue
    expect(number_of_payloads).to be > 10
  end

end