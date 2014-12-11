require_relative 'test_helper'
require_relative 'metainfo_test_helper'
require_relative 'peer_test_helper'
require_relative 'swarm_test_helper'
require_relative '../lib/kademlia/swarm'

describe Swarm do
  it "can be created with a torrent file" do
    s = Swarm.new(Metainfo.default_file)
  end

  it "can handle a HaveMessage" do
    s = Swarm.new(Metainfo.default_file)
    b_dir = s.block_directory
    peer = Peer.default
    b_dir.all_pieces(peer).include?(b_dir.pieces[0]).must_equal false 
    
    have_message = HaveMessage.Create(0)
    s.process_message(have_message, peer)
    
    b_dir.all_pieces(peer).include?(b_dir.pieces[0]).must_equal true 
  end

  it "can handle a BitfieldMessage" do
    s = Swarm.new(Metainfo.default_file)
    b_dir = s.block_directory
    peer = Peer.default
    b_dir.all_pieces(peer).include?(b_dir.pieces[6]).must_equal false
    b_dir.all_pieces(peer).include?(b_dir.pieces[7]).must_equal false 

    bitfield_message = BitfieldMessage.Create("00000011")
    s.process_message(bitfield_message, peer)

    b_dir.all_pieces(peer).include?(b_dir.pieces[6]).must_equal true
    b_dir.all_pieces(peer).include?(b_dir.pieces[7]).must_equal true 
  end

  it "can handle a PieceMessage" do
    s = Swarm.new(Metainfo.default_file)
    b_dir = s.block_directory
    b_dir.clear
    b_dir.completed_blocks.include?(b_dir.pieces[0].blocks[0]).must_equal false

    piece_message = PieceMessage.Create(0, 0, "A")
    s.process_message(piece_message, Peer.default)
    
    b_dir.completed_blocks.include?(b_dir.pieces[0].blocks[0]).must_equal true 
  end

  it "can determine the interesting peers" do
    s = Swarm.new(Metainfo.default_file)

    # simulating a payload for the bitfield of 0b00000011
    payload = PeerMessage.id_to_wire(5) + [3].pack("C")
    bitfield_message = PeerMessage.Create(2, payload)
    bitfield_message.class.must_equal BitfieldMessage

    s.process_message(bitfield_message, Peer.default)
    s.interesting_peers.length.must_equal 1
  end

  it "can download a piece" do
    s = Swarm.default
    completed_piece_count = s.block_directory.completed_pieces.length
    s.start

    while(s.block_directory.completed_pieces.length <= completed_piece_count) 
      sleep(2)
    end

    s.stop
  end
end
