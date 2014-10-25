require_relative 'test_helper'
require_relative '../lib/kademlia/node'

describe Node do
  test_id = 1
  test_ip = "127.0.0.1"
  test_port = 6881

  it "must have an id, ip, and port" do
    node = Node.new(test_id, test_ip, test_port)

    node.id.must_equal test_id
    node.ip.must_equal test_ip
    node.port.must_equal test_port 
  end

  it "must be bencodable" do
    node = Node.new(test_id, test_ip, test_port)
    node.bencode.must_equal "d2:idi1e2:ip9:127.0.0.14:porti6881ee"
  end

end
