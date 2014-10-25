require_relative 'test_helper'
require_relative '../lib/kademlia/peer'

describe Peer do
  test_id = "abcdefghijklmnoprstu"
  test_ip = "127.0.0.1"
  test_port = 6881

  it "must create an id 20 bytes long if none is specified" do
    peer = Peer.new(test_ip, test_port)
    peer.id.length.must_equal 20
  end 

  it "must fail to create a node with an invalid id" do
    assert_raises(InvalidPeerError) { peer = Peer.new(test_ip, test_port, test_id + "1") }
  end

  it "must be able to shake hands" do
    response = Peer.shake_hands
    
  end
end
