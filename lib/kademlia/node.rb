require 'bencode'

class Node
  attr_reader :id
  attr_reader :ip
  attr_reader :port

  def initialize (id, ip, port)
    @id = id
    @ip = ip
    @port = port
  end

  def bencode
    {"id" => @id, "ip" => @ip, "port" => @port}.bencode
  end

  def ==(other_node)
    return false if other_node.class != Node

    # Default behavior is to test object_id with equal?
    return true if other_node.equal?(self)

    other_node.id   == self.id   &&
    other_node.ip   == self.ip   &&
    other_node.port == self.port
  end
end
