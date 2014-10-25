require_relative '../lib/kademlia/torrent'
require_relative 'test_helper'

describe Torrent do
  it "can be created with a torrent file" do
    t = Torrent.new(File.dirname(__FILE__) + '/ubuntu.torrent')
  end

  it "can get a list of peers" do
    t = Torrent.new(File.dirname(__FILE__) + '/ubuntu.torrent')
    (t.peers.length > 1).must_equal true
  end
end
