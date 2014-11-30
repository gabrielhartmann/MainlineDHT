require_relative '../lib/kademlia/block_directory'
require_relative 'torrent_file_io_test_helper'

class BlockDirectory 

  def self.default
    BlockDirectory.new(TorrentFileIO.default.metainfo, TorrentFileIO.default)
  end
end
