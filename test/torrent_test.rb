require_relative 'test_helper'
require_relative 'torrent_test_helper'
require_relative '../lib/kademlia/messages'

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

  it "can write a piece to a file" do
    # A piece message has id 7 according to the spec
    id = 7
    index = beg = 0
    block = 5
    
    # Simulating a payload for a 1 byte block of 0b00000101
    sim_payload = [id, index, beg, block, block+1, block+2].pack("CL>L>C*")

    message = PeerMessage.Create(sim_payload.length, sim_payload)

    t = Torrent.default
    t.write(message)
  end

  it "can get a bitfield" do
    t = Torrent.default
    t.get_bitfield
  end
end
