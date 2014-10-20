require_relative 'test_helper'
require_relative 'node_test_helper'
require_relative '../lib/kademlia/bucket'
require_relative '../lib/kademlia/id'
require_relative '../lib/kademlia/node'

describe Bucket do
  local_node = Node.new(Id.generate, "127.0.0.1", 6881)
  id_range = (0..2**160) 

  it "can be created with an id range" do
    b = Bucket.new(local_node, id_range)
    b.id_range.must_equal id_range
  end

  it "can be split into two buckets" do
    b = Bucket.new(local_node, id_range)

    Bucket.k_factor.times {b.add(Node.random)}
    bucket_low, bucket_high = b.split

    bucket_low.id_range.must_equal(0..2**160/2)
    bucket_high.id_range.must_equal(2**160/2+1..2**160)

    b.nodes.length.must_equal bucket_low.nodes.length + bucket_high.nodes.length 
  end

  it "can have Nodes added to it" do
    b = Bucket.new(local_node, id_range)
    b.nodes.length.must_equal 0
    b.add(local_node)
    b.nodes.length.must_equal 1
    b.nodes.first.must_equal local_node
  end

  it "must not allow more nodes to be added than the k_factor" do
    b = Bucket.new(local_node, id_range)
    too_many_nodes = Bucket.k_factor+1
    assert_raises(BucketCapacityError) { too_many_nodes.times {b.add(Node.random)} }
    b.nodes.length.must_equal Bucket.k_factor
  end

  it "can identify whether the local node lies within its ID range" do
    b = Bucket.new(local_node, id_range)
    b.include_local_node?.must_equal true
  end

  it "cannot add duplicate nodes" do 
    b = Bucket.new(local_node, id_range)
    assert_raises(BucketDuplicateError) { 2.times { b.add(local_node) } }
  end

  it "cannot add nodes which are internally identical" do
    b = Bucket.new(local_node, id_range)
    
    node_a = Node.new(1, "127.0.0.1", 6881)
    node_b = Node.new(1, "127.0.0.1", 6881)

    b.add(node_a)
    assert_raises(BucketDuplicateError) { b.add(node_b) }
  end
end
