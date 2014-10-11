require_relative 'bucket'

class RoutingTable
  attr_reader :id_space
  attr_reader :buckets

  @@Default_Id_Space = (0..2**160) 

  def self.default_id_space
    @@Default_Id_Space
  end

  def initialize (id_space = @@Default_Id_Space)
    @id_space = id_space
    @buckets = Array.new(1) {Bucket.new(id_space)}
  end
  
  def add (node)
    @buckets.each { |b| b.add(node) if b.id_range.include?(node.peer_id) }
  end

  def nodes
    nodes = Array.new
    @buckets.each { |b| nodes.push(*b.nodes) }
  end

end
