require_relative 'test_helper'
require_relative 'peer_test_helper'
require_relative '../lib/kademlia/peer'
require_relative '../lib/kademlia/swarm'

describe Peer do
  test_id = "abcdefghijklmnoprstu"
  test_ip = "127.0.0.1"
  test_port = 6881
  test_hashed_info = 12345678901234567890
  test_local_peer_id = "abcdefghijklmnopqrst"
  id_length = 20
  info_hash_length = id_length
  
  test_peer = Peer.default

  it "must create an id 20 bytes long if none is specified" do
    test_peer.id.length.must_equal 20
  end 

  it "must fail to create a node with an invalid id" do
    assert_raises(InvalidPeerError) { peer = Peer.new(nil, test_ip, test_port, test_hashed_info, test_local_peer_id, test_id + "1") }
  end

  it "must be able to shake hands" do
    p = Peer.default_peers.sample
    response = p.shake_hands

    response.length.must_equal 19
    response.protocol.must_equal "BitTorrent protocol"
    response.info_hash.length.must_equal info_hash_length
    response.peer_id.length.must_equal id_length 
    response.peer_id.must_equal p.id
  end

  it "must fail to determine whether an uninitialized Peer supports DHT" do
    p = Peer.new(nil, test_ip, test_port, test_hashed_info, test_local_peer_id)
    assert_raises(InvalidPeerError) { p.supports_dht? }
  end

  it "must be able to generate appropriate request messages" do
    s = Swarm.new(Metainfo.default_file)
    s.block_directory.clear
    p = Peer.default
    p.join(s)

    have_message = HaveMessage.Create(0)
    s.process_message(have_message, p)

    request_message = p.get_next_request
    request_message.class.must_equal RequestMessage
    request_message.index.must_equal have_message.piece_index
  end
  
  it "must be able to determine whether it is interesting" do
    s = Swarm.default
    p = Peer.default
    piece_index = 100
    p.join(s)

    p.is_interesting?.must_equal false

    have_message = HaveMessage.Create(piece_index)
    s.process_message(have_message, p)

    p.is_interesting?.must_equal true
    s.block_directory.clear_piece_peers(piece_index)
    p.is_interesting?.must_equal false
  end

  it "must be able to connect and disconnect from a peer" do
    s = Swarm.default
    p = Peer.default
    p.join(s)
    p.connect

    p.msg_proc_thread.alive?.must_equal true 
    p.read_thread.alive?.must_equal true
    p.write_thread.alive?.must_equal true

    sleep(5)
    p.disconnect

    p.msg_proc_thread.stop?.must_equal true 
    p.read_thread.stop?.must_equal true 
    p.write_thread.stop?.must_equal true 

    s.block_directory.clear
  end

  it "must be able to read messages from the wire" do
  #   peer_count = [Peer.default_peers.length, 5].min
  #   peers = Peer.default_peers[0..peer_count-1]
  #   peers.each do |p|
  #      begin
  #        puts "ip: #{p.ip} port: #{p.port}"
  #        p.shake_hands
  #        message = p.read_next_message
  #        puts message.class
  #      rescue StandardError => e
  #        puts e.inspect
  #      end
  #    end
  end

end
