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

  it "can determine the already downloaded pieces" do
    metainfo = Metainfo.new(File.dirname(__FILE__) + '/tc08.mp3.torrent')
    io = TorrentFileIO.new(metainfo, File.dirname(__FILE__) + "/" + metainfo.info.name + ".part")
    block_dir = BlockDirectory.new(metainfo, io)
    
    pieces = block_dir.refresh_pieces
    pieces.length.must_equal 8

    block_dir.completed_pieces.length.must_equal 1
  end

  it "can add peers to pieces" do
    block_dir = BlockDirectory.new(Metainfo.default, TorrentFileIO.new(Metainfo.default))

    # Add a peer to a piece and verify length and contents of the Piece's Peers
    block_dir.add_peer_to_piece(0, Peer.default)
    block_dir.pieces[0].peers.length.must_equal 1
    block_dir.pieces[0].peers[0].must_equal Peer.default

    # Add the same peer again.  Nothing should change, as we shouldn't add duplicates
    block_dir.add_peer_to_piece(0, Peer.default)
    block_dir.pieces[0].peers.length.must_equal 1
    block_dir.pieces[0].peers[0].must_equal Peer.default
  end
end
