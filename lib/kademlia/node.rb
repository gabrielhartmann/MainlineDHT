class Node
  attr_accessor :routing_table

  def initialize
    self.routing_table = RoutingTable.new
  end
end
