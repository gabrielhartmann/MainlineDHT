class Node
  attr_reader :routing_table

  def initialize
    @routing_table = RoutingTable.new
  end
end
