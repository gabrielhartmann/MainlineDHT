require_relative 'test_helper'
require_relative 'peer_test_helper'
require_relative '../lib/kademlia/peer'

describe Peer do
  test_id = "abcdefghijklmnoprstu"
  test_ip = "127.0.0.1"
  test_port = 6881
  test_hashed_info = 12345678901234567890
  test_local_peer_id = "abcdefghijklmnopqrst"
  id_length = 20
  info_hash_length = id_length
  
  test_peer = Peer.new(test_ip, test_port, test_hashed_info, test_local_peer_id)


  it "must create an id 20 bytes long if none is specified" do
    test_peer.id.length.must_equal 20
  end 

  it "must fail to create a node with an invalid id" do
    assert_raises(InvalidPeerError) { peer = Peer.new(test_ip, test_port, test_hashed_info, test_local_peer_id, test_id + "1") }
  end

  it "must be able to shake hands" do
    p = Peer.default
    response = p.shake_hands

    response.length.must_equal 19
    response.protocol.must_equal "BitTorrent protocol"
    response.info_hash.length.must_equal info_hash_length
    response.peer_id.length.must_equal id_length 
    response.peer_id.must_equal p.id
  end

  it "must fail to determine whether an uninitialized Peer supports DHT" do
    assert_raises(InvalidPeerError) { test_peer.supports_dht? }
  end

end
