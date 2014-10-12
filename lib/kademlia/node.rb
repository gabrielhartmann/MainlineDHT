require 'bencode'

class Node
  attr_reader :peer_id
  attr_reader :ip
  attr_reader :port

  def initialize (peer_id, ip, port)
    @peer_id = peer_id
    @ip = ip
    @port = port
  end

  def bencode
    {"peer_id" => @peer_id, "ip" => @ip, "port" => @port}.bencode
  end

  def ==(other_node)
    return false if other_node.class != Node

    # Default behavior is to test object_id with equal?
    return true if other_node.equal?(self)

    other_node.peer_id == self.peer_id &&
    other_node.ip      == self.ip      &&
    other_node.port    == self.port
  end
end
