require_relative '../spec_helper'
require 'curb'

describe ThinConnector::Stream::GNIPStream do

  let!(:url)     { 'https://stream.gnip.com:443/accounts/isaacs/publishers/twitter/streams/track/prod.json' }
  let!(:headers) {
    {
        authorization: %w(nisaacs@splickit.com suckstwosuck),
        'Accept-Encoding' => 'gzip,deflate,sdch'
    }
  }
  let(:stream)   { ThinConnector::Stream::GNIPStream.new(url, headers) }

  it 'should start and stop the stream' do
    @data=[]
    t = Thread.new do
      stream.start{ |data| @data << data }
    end

    sleep 6
    stream.stop
    t.join

    expect(@data.size).to be > 0
  end

  it 'should handle at least as much throughput as curl' do
    compare_time_seconds = 15
    puts "Running for #{compare_time_seconds} seconds"
    acceptable_difference = 10000


    @base_payloads_recieved=10;
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
    puts "Curl got: #{@base_payloads_recieved} App got: #{@count}"

    expect(abs_difference < acceptable_difference).to be_true
  end
end