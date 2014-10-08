require_relative 'test_helper'
require_relative '../lib/kademlia/routing_table'

describe RoutingTable do
  it "can be created with a default id space" do
    routing_table = RoutingTable.new
    routing_table.id_space.must_equal RoutingTable::Default_Id_Space
  end

  it "can be created witha a custom id space" do
    id_space = 3
    routing_table = RoutingTable.new(id_space)
    routing_table.id_space.must_equal id_space
  end

  it "can report the number of buckets it has" do
    routing_table = RoutingTable.new
    routing_table.bucket_count.must_equal 1
  end
end
