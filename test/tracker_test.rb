require_relative 'test_helper'
require_relative 'tracker_test_helper'
require_relative 'logger_test_helper'
require_relative '../lib/kademlia/tracker'

describe Tracker do
  it "can be created with a torrent file" do
    Tracker.default
  end

  it "can get a list of peers" do
    (Tracker.default.peers.length >= 6).must_equal true
  end

  it "cannot be created with an invalid peer id" do
    assert_raises(InvalidPeerError) { Tracker.new(Logger.default, Metainfo.default, "a") }
  end

  it "can be created with a valid peer id" do
    Tracker.new(Logger.default, Metainfo.default, "abcdefghijklmnopqrst")
  end

 # it "must find some peers which support DHT" do
 #   t = Torrent.default
 #   t.peers.each do |p|
 #      p.shake_hands
 #      return if p.supports_dht?
 #   end

 #   raise StandardError, "Failed to find a peer which supports DHT"
 # end
end
