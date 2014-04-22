require_relative '../spec_helper'
require 'curb'

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
    @data=nil
    t = Thread.new do
      stream.start{ |data| @data = data }
    end

    sleep 6
    stream.stop
    t.join

    expect(@data).not_to be_nil
  end

  it 'should handle at least as much throughput as curl' do
    compare_time_seconds = 10
    acceptable_difference = 100


    @base_payloads_recieved=0;
    compare_collection_thread = Thread.new do
      Curl::Easy.http_get url do |c|
        c.username = headers[:authorization].first
        c.password = headers[:authorization].last
        c.encoding = 'gzip'
        c.on_body{ |a| @base_payloads_recieved += 1; a.size }
      end
    end

    sleep compare_time_seconds
    compare_collection_thread.kill
    sleep 1 while compare_collection_thread.alive?


    @count=0
    t = Thread.new{ stream.start{ |data| @count += 1 } }
    sleep compare_time_seconds
    stream.stop
    t.join
    sleep 1 while t.alive?
    abs_difference = (@count - @base_payloads_recieved).abs

    expect(abs_difference < acceptable_difference).to be_true
  end
end