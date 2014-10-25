require_relative '../lib/kademlia/torrent.rb'

class Torrent
  def self.default
    return Torrent.new(File.dirname(__FILE__) + '/ubuntu.torrent')
  end
end
