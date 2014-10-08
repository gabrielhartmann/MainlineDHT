require_relative '../test_helper'
require_relative '../../lib/kademlia/node'
require_relative '../../lib/kademlia/routing_table'

describe Kademlia do

  it "it must have a routing table" do
    node = Node.new
    node.routing_table.must_be_instance_of RoutingTable
  end

end
