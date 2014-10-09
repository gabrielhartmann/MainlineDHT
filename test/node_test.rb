require_relative 'test_helper'
require_relative '../lib/kademlia/node'

describe Node do

  it "it must have a peer_id, ip, and port" do
    peer_id = 1
    ip = "127.0.0.1"
    port = 6881

    node = Node.new(peer_id, ip, port)
    node.peer_id.must_equal peer_id
    node.ip.must_equal ip
    node.port.must_equal port 
  end

end
