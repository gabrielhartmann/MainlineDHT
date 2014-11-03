require_relative 'metainfo_test_helper'
require_relative '../lib/kademlia/torrent'

class Torrent
  @@default_torrent = nil

  def self.default
    if (!@@default_torrent)
      @@default_torrent = Torrent.new(Metainfo.default_file)
    end

    return @@default_torrent
  end
end
