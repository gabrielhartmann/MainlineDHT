require_relative 'test_helper'
require_relative 'node_test_helper'
require_relative '../lib/kademlia/id'
require_relative '../lib/kademlia/node'
require_relative '../lib/kademlia/routing_table'

describe RoutingTable do
  local_node = Node.new(Id.generate, "127.0.0.1", 6881)

  it "can be created with a default id space" do
    routing_table = RoutingTable.new(local_node)
    routing_table.id_space.must_equal RoutingTable::default_id_space
  end

  it "can be created with a custom id space" do
    id_space = (0..7) 
    routing_table = RoutingTable.new(local_node, id_space)
    routing_table.id_space.must_equal id_space
  end

  it "must have one bucket when initially created" do
    routing_table = RoutingTable.new(local_node)
    routing_table.buckets.length.must_equal 1
  end

  it "must be able to add nodes" do
    routing_table = RoutingTable.new(local_node)
    node = Node.new(Id.generate, "127.0.0.1", 6881)
    
    routing_table.add(node)
    routing_table.nodes.length.must_equal 1
  end

  it "must fail to add non-nodes" do
    routing_table = RoutingTable.new(local_node)
    assert_raises(RoutingTableTypeError) {routing_table.add(42)}
  end

  it "must split a bucket when a bucket hits capacity and contains the local node" do
    routing_table = RoutingTable.new(local_node)

    one_extra_time = Bucket.k_factor + 1
    one_extra_time.times {routing_table.add(Node.random)}

    (routing_table.buckets.length > 1).must_equal true
  end

  it "must be able to add 1000 nodes" do
      routing_table = RoutingTable.new(local_node)
      1000.times do |i|
	routing_table.add(Node.random)
      end

      added_nodes_count = routing_table.nodes.length
      bucket_count = routing_table.buckets.length
      
      valid_ratio = bucket_count * Bucket.k_factor > added_nodes_count
      valid_ratio.must_equal true

      routing_table.buckets.each do |b|
	(b.nodes.length <= Bucket.k_factor).must_equal true
      end
  end

  it "must fail to add nodes with invalid peer ids" do
    routing_table = RoutingTable.new(local_node)
    assert_raises(RoutingTableRangeError) { routing_table.add(Node.new(-1, "127.0.0.1", 6881)) }
  end
end
