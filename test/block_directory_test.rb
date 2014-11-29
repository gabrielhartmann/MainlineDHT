require_relative 'test_helper'
require_relative 'metainfo_test_helper'
require_relative 'peer_test_helper'
require_relative '../lib/kademlia/block_directory'
require_relative '../lib/kademlia/torrent_file_io'

describe BlockDirectory do
  it "can be created" do
    block_dir = BlockDirectory.new(Metainfo.default, TorrentFileIO.new(Metainfo.default))
    block_dir.pieces.length.must_equal 1522
    block_dir.completed_pieces.length.must_equal 0
  end

  it "can determine the complete pieces of a partial file" do
    metainfo = Metainfo.new(File.dirname(__FILE__) + '/tc08.mp3.torrent')
    io = TorrentFileIO.new(metainfo, File.dirname(__FILE__) + "/" + metainfo.info.name + ".part")
    block_dir = BlockDirectory.new(metainfo, io)
    
    pieces = block_dir.refresh_pieces
    block_dir.completed_pieces.length.must_equal 1
  end

  it "can determine the incomplete pieces of a partial file" do
    metainfo = Metainfo.new(File.dirname(__FILE__) + '/tc08.mp3.torrent')
    io = TorrentFileIO.new(metainfo, File.dirname(__FILE__) + "/" + metainfo.info.name + ".part")
    block_dir = BlockDirectory.new(metainfo, io)

    pieces = block_dir.refresh_pieces
    block_dir.incomplete_pieces.length.must_equal 7
  end

  it "can determine the complete pieces of a complete file" do
    metainfo = Metainfo.new(File.dirname(__FILE__) + '/tc08.mp3.torrent')
    io = TorrentFileIO.new(metainfo, File.dirname(__FILE__) + "/" + metainfo.info.name)
    block_dir = BlockDirectory.new(metainfo, io)
    
    pieces = block_dir.refresh_pieces
    block_dir.completed_pieces.length.must_equal 8
  end

  it "can determine the incomplete pieces of a complete file" do
    metainfo = Metainfo.new(File.dirname(__FILE__) + '/tc08.mp3.torrent')
    io = TorrentFileIO.new(metainfo, File.dirname(__FILE__) + "/" + metainfo.info.name)
    block_dir = BlockDirectory.new(metainfo, io)

    pieces = block_dir.refresh_pieces
    block_dir.incomplete_pieces.length.must_equal 0
  end

  it "can add peers to pieces" do
    block_dir = BlockDirectory.new(Metainfo.default, TorrentFileIO.new(Metainfo.default))
    block_dir.available_pieces.length.must_equal 0

    # Add a peer to a piece and verify length and contents of the Piece's Peers
    block_dir.add_peer_to_piece(0, Peer.default)
    block_dir.pieces[0].peers.length.must_equal 1
    block_dir.pieces[0].peers[0].must_equal Peer.default

    # Add the same peer again.  Nothing should change, as we shouldn't add duplicates
    block_dir.add_peer_to_piece(0, Peer.default)
    block_dir.pieces[0].peers.length.must_equal 1
    block_dir.pieces[0].peers[0].must_equal Peer.default
  end

  it "can remove a peer from all pieces" do
    block_dir = BlockDirectory.new(Metainfo.default, TorrentFileIO.new(Metainfo.default))
    block_dir.available_pieces.length.must_equal 0
    
    block_dir.add_peer_to_piece(0, Peer.default)
    block_dir.available_pieces.length.must_equal 1

    block_dir.remove_peer(Peer.default)
    block_dir.available_pieces.length.must_equal 0
  end

  it "can determine the pieces available for download" do
    block_dir = BlockDirectory.new(Metainfo.default, TorrentFileIO.new(Metainfo.default))
    block_dir.add_peer_to_piece(0, Peer.default)
    block_dir.available_pieces.length.must_equal 1
  end

  it "can determine available and unavailable pieces before and after a peer is added" do
    block_dir = BlockDirectory.new(Metainfo.default, TorrentFileIO.new(Metainfo.default))

    unavailable_piece_count = block_dir.incomplete_pieces.length
    available_piece_count = block_dir.completed_pieces.length
    
    block_dir.add_peer_to_piece(0, Peer.default)
    
    block_dir.available_pieces.length.must_equal available_piece_count + 1
    block_dir.unavailable_pieces.length.must_equal unavailable_piece_count - 1
  end

  it "generates valid block offsets and sizes for all pieces" do
    block_dir = BlockDirectory.new(Metainfo.default, TorrentFileIO.new(Metainfo.default))

    block_dir.pieces.each do |piece|
      block_length_sum = 0
      (0..piece.blocks.length-1).each do |index|
	block = piece.blocks[index]
	block_length_sum += block.length
	(block.length <= Block.max_length).must_equal true

	if (index+1 < piece.blocks.length)
	  next_block = piece.blocks[index+1]
	  next_block.offset.must_equal block.offset + block.length
	end
      end

      block_length_sum.must_equal piece.length
    end
  end

  it "can mark a block as complete" do
    block_dir = BlockDirectory.new(Metainfo.default, TorrentFileIO.new(Metainfo.default))
    block_dir.pieces[0].blocks[0].complete?.must_equal false
    block_dir.finish_block(0, 0)
    block_dir.pieces[0].blocks[0].complete?.must_equal true 
  end

  it "can get the incomplete pieces which a particular peer can provide" do
    block_dir = BlockDirectory.new(Metainfo.default, TorrentFileIO.new(Metainfo.default))

    pieces = block_dir.incomplete_pieces(Peer.default)
    pieces.length.must_equal 0
    
    block_dir.add_peer_to_piece(0, Peer.default)

    pieces = block_dir.incomplete_pieces(Peer.default)
    pieces.length.must_equal 1
    pieces.first.must_equal block_dir.pieces[0]
  end
  
  it "can get the incomplete blocks which a particular peer can provide" do
    block_dir = BlockDirectory.new(Metainfo.default, TorrentFileIO.new(Metainfo.default))

    pieces = block_dir.incomplete_blocks(Peer.default)
    pieces.length.must_equal 0
    
    block_dir.add_peer_to_piece(0, Peer.default)

    blocks = block_dir.incomplete_blocks(Peer.default)
    blocks.length.must_equal 32
  end
end
