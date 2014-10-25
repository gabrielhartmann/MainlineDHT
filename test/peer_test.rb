require_relative 'test_helper'
require_relative 'torrent_test_helper'
require_relative '../lib/kademlia/peer'

describe Peer do
  test_id = "abcdefghijklmnoprstu"
  test_ip = "127.0.0.1"
  test_port = 6881
  test_hashed_info = 12345678901234567890
  test_local_peer_id = "abcdefghijklmnopqrst"
  id_length = 20
  info_hash_length = id_length

  it "must create an id 20 bytes long if none is specified" do
    peer = Peer.new(test_ip, test_port, test_hashed_info, test_local_peer_id)
    peer.id.length.must_equal 20
  end 

  it "must fail to create a node with an invalid id" do
    assert_raises(InvalidPeerError) { peer = Peer.new(test_ip, test_port, test_hashed_info, test_local_peer_id, test_id + "1") }
  end

  it "must be able to shake hands" do
    t = Torrent.default
    p = t.peers.first
    response = p.shake_hands
    response.length.must_equal "\x13"
    response.protocol.must_equal "BitTorrent protocol"
    response.info_hash.length.must_equal info_hash_length
    response.peer_id.length.must_equal id_length 
  end
end
