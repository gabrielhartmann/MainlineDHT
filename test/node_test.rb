require_relative 'test_helper'
require_relative '../lib/kademlia/node'

describe Node do

  it "must have a peer_id, ip, and port" do
    peer_id = 1
    ip = "127.0.0.1"
    port = 6881
    node = Node.new(peer_id, ip, port)

    node.peer_id.must_equal peer_id
    node.ip.must_equal ip
    node.port.must_equal port 
  end

  it "must be bencodable" do
    peer_id = 1
    ip = "127.0.0.1"
    port = 6881
    node = Node.new(peer_id, ip, port)

    node.bencode.must_equal "d2:ip9:127.0.0.17:peer_idi1e4:porti6881ee"
  end

end
