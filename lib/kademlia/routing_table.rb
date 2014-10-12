require_relative 'bucket'

class RoutingTable
  attr_reader :id_space
  attr_reader :buckets

  @@Default_Id_Space = (0..2**160) 

  def self.default_id_space
    @@Default_Id_Space
  end

  def initialize (local_node, id_space = @@Default_Id_Space)
    raise RoutingTableTypeError, "id_space must be a Range" unless id_space.class == Range
    @id_space = id_space
    @buckets = Array.new(1) {Bucket.new(local_node, id_space)}
  end
  
  def add (node)
    raise RoutingTableTypeError, "node must be a Node" unless node.class == Node
    @buckets.each { |b| b.add(node) if b.id_range.include?(node.peer_id) }
  end

  def nodes
    nodes = Array.new
    @buckets.each { |b| nodes.push(*b.nodes) }
  end

end

class RoutingTableTypeError < StandardError
end
