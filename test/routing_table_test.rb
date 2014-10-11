require_relative 'test_helper'
require_relative '../lib/kademlia/id'
require_relative '../lib/kademlia/node'
require_relative '../lib/kademlia/routing_table'

describe RoutingTable do
  it "can be created with a default id space" do
    routing_table = RoutingTable.new
    routing_table.id_space.must_equal RoutingTable::default_id_space
  end

  it "can be created with a custom id space" do
    id_space = 3
    routing_table = RoutingTable.new(id_space)
    routing_table.id_space.must_equal id_space
  end

  it "must have one bucket when initially created" do
    routing_table = RoutingTable.new
    routing_table.buckets.length.must_equal 1
  end

  it "must be able to add nodes" do
    routing_table = RoutingTable.new
    node = Node.new(Id.generate, "127.0.0.1", 6881)
    
    routing_table.add(node)
    routing_table.nodes.length.must_equal 1
  end
end
