require_relative 'test_helper'
require_relative '../lib/kademlia/bucket'
require_relative '../lib/kademlia/node'

describe Bucket do
  it "can be created with an id range" do
    id_range = (0..2**160) 
    bucket = Bucket.new (id_range)
    bucket.id_range.must_equal id_range
  end

  it "can be split into two buckets" do
    id_range = (0..2**160)
    bucket_orig = Bucket.new (id_range)
    bucket_low, bucket_high = bucket_orig.split
    bucket_low.id_range.must_equal(0..2**160/2)
    bucket_high.id_range.must_equal(2**160/2+1..2**160)
  end

  it "can have Nodes added to it" do
    id_range = (0..2**160)
    bucket = Bucket.new (id_range)

    peer_id = 1
    ip = "127.0.0.1"
    port = 6881
    node = Node.new(peer_id, ip, port)

    bucket.nodes.length.must_equal 0
    bucket.add(node)
    bucket.nodes.length.must_equal 1
    bucket.nodes.first.must_equal node
  end
end
