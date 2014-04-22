
require_relative '../spec_helper'

describe ThinConnector::Processor::ActiveRecordStreamProcessor do

  let!(:environment)    { ThinConnector::Environment.instance }
  let!(:url)            { 'https://stream.gnip.com:443/accounts/isaacs/publishers/twitter/streams/track/prod.json' }
  let!(:headers)        {
    {
        authorization: [environment.gnip_username, environment.gnip_password],
        'Accept-Encoding' => 'gzip,deflate,sdch'
    }
  }

  let!(:stream)         { ThinConnector::Stream::GNIPStream.new(url, headers) }
  let(:processor) { ThinConnector::Processor::ActiveRecordStreamProcessor.new stream }

  it 'should place the stream into the database' do
    test_time_in_seconds = 10
    stream_thread = Thread.new do
      processor.start
    end

    sleep test_time_in_seconds
    processor.stop
    stream_thread.join
    objects = ThinConnector::Models::Tweet.all

    expect(objects.size).to be > 0
  end

end