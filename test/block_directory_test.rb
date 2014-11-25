require_relative 'test_helper'
require_relative 'metainfo_test_helper'
require_relative '../lib/kademlia/block_directory'
require_relative '../lib/kademlia/torrent_file_io'

describe BlockDirectory do
  it "can be created" do
    BlockDirectory.new(Metainfo.default, TorrentFileIO.new(Metainfo.default))
  end

  it "can determine the already downloaded pieces" do
    metainfo = Metainfo.new(File.dirname(__FILE__) + '/tc08.mp3.torrent')
    io = TorrentFileIO.new(metainfo, File.dirname(__FILE__) + "/" + metainfo.info.name + ".part")
    block_dir = BlockDirectory.new(metainfo, io)
    
    pieces = block_dir.refresh_completed_pieces
    pieces.length.must_equal 8

    block_dir.completed_pieces.length.must_equal 1
  end
end
