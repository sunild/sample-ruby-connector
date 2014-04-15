require_relative '../spec_helper'

describe ThinConnector::Stream::GNIPStream do

  let!(:url)     { 'https://stream.gnip.com:443/accounts/isaacs/publishers/twitter/streams/track/prod.json' }
  let!(:headers) {
    {
        authorization: ['nisaacs@splickit.com', 'suckstwosuck'],
        'Accept-Encoding' => 'gzip,deflate,sdch'
    }
  }
  let(:stream)   { ThinConnector::Stream::GNIPStream.new(url, headers) }

  it 'should start the stream' do
    @data
    stream.start{ |data| puts (@data = data) }
  end

  it 'should handle the minimum required throughput' do
    @count=0
    t = Thread.new{ stream.start{ @count += 1 } }
    sleep 60
    t.kill
    expect(@count > 1000).to be_true
  end
end