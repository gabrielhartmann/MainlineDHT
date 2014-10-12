require_relative '../lib/kademlia/routing_table'

class Node
  def self.random
    # Random node ID
    node_id = rand(RoutingTable.default_id_space)

    # Random IP address
    ip = String.new
    4.times{ ip << (rand(0..127).to_s + ".") }
    ip = ip[0..-2] # Drop the last "."

    # Random port
    port = rand(0..2**16-1)

    Node.new(node_id, ip, port)
  end
end
