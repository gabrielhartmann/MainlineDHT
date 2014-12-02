require_relative 'swarm_test_helper'

class Peer
  @@default_peer = nil
  @@default_peers = nil

  def self.default
    if (!@@default_peer)
      @@default_peer = Swarm.default.peers.sample
    end

    return @@default_peer
  end

  def self.default_peers
    if (!@@default_peers)
      @@default_peers = Swarm.default.peers
    end

    return @@default_peers
  end

  def self.random
    Peer.default_peers.sample
  end
end
