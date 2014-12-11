require_relative 'metainfo_test_helper.rb'
require_relative 'logger_test_helper'
require_relative '../lib/kademlia/torrent_file_io'

class TorrentFileIO 
  @@default_torrent_file_io = nil
  def self.default
    if (!@@default_torrent_file_io)
      metainfo = Metainfo.default
      @@default_torrent_file_io =  TorrentFileIO.new(Logger.default, metainfo, File.dirname(__FILE__) + "/" + metainfo.info.name + ".part")
    end

    return @@default_torrent_file_io
  end
end
