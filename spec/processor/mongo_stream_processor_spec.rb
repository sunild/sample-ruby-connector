require 'mongo'
require_relative '../spec_helper'

def wait(time)
  finish = Time.now + time
  while Time.now < finish
  end
end


describe ThinConnector::Processor::MongoStreamProcessor do

  let!(:environment)    { ThinConnector::Environment.instance }
  let!(:url)            { 'https://stream.gnip.com:443/accounts/isaacs/publishers/twitter/streams/track/prod.json' }
  let!(:headers)        {
    {
        authorization: [environment.gnip_username, environment.gnip_password],
        'Accept-Encoding' => 'gzip,deflate,sdch'
    }
  }

  let!(:stream)         { ThinConnector::Stream::GNIPStream.new(url, headers) }
  let(:mongo_processor) { ThinConnector::Processor::MongoStreamProcessor.new stream }
  let!(:mongo)          {
                          config = ThinConnector::Environment.instance.mongo_config
                          Mongo::MongoClient.new(config[:host], config[:port]).db config[:database]
                        }
  let(:mongo_collection){ mongo.collection 'tweets' }

  it 'should put the payloads into the appropriate Mongo collection' do
    mongo_collection.drop
    processing_thread = Thread.new do
      mongo_processor.start
    end

    sleep 10
    mongo_processor.stop
    processing_thread.join
    stats = mongo_collection.stats
    puts stats
    number_of_payloads = stats['size']
    expect(number_of_payloads).to be > 10
  end

end