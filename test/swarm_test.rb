require_relative 'test_helper'
require_relative 'metainfo_test_helper'
require_relative '../lib/kademlia/swarm'

describe Swarm do
  it "can be created with a torrent file" do
    s = Swarm.new(Metainfo.default_file)
  end
end
