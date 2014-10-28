require_relative 'torrent_test_helper'

class Peer
  @@default_peer = nil
  @@default_peers = nil

  def self.default
    if (!@@default_peer)
      @@default_peer = Torrent.default.peers.first
    end

    return @@default_peer
  end

  def self.default_peers
    if (!@@default_peers)
      @@default_peers = Torrent.default.peers
    end

    return @@default_peers
  end
end
