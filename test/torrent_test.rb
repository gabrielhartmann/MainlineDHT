require_relative 'test_helper'
require_relative 'torrent_test_helper.rb'

describe Torrent do
  it "can be created with a torrent file" do
    Torrent.default
  end

  it "can get a list of peers" do
    t = Torrent.default
    (t.peers.length > 1).must_equal true
  end

  it "must find some peers which support DHT" do
    t = Torrent.default
    t.peers.each do |p|
       p.shake_hands
       return if p.supports_dht?
    end

    raise StandardError, "Failed to find a peer which supports DHT"
  end
end
