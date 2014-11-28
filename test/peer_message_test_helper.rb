require_relative '../lib/kademlia/messages'

class PeerMessage
  def self.id_to_wire(id)
    [id].pack("C")
  end
end
