require_relative '../lib/kademlia/torrent.rb'

class Torrent
  @@default_torrent = nil

  def self.default
    if (!@@default_torrent)
      @@default_torrent = Torrent.new(File.dirname(__FILE__) + '/ubuntu.torrent')
    end

    return @@default_torrent
  end
end
