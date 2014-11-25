require_relative 'metainfo_test_helper'
require_relative '../lib/kademlia/swarm'

class Swarm
  @@default_swarm = nil

  def self.default
    if (!@@default_swarm)
     @@default_swarm = Swarm.new(Metainfo.default_file)
    end

    return @@default_swarm
  end
end
