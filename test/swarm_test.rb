require_relative 'test_helper'
require_relative 'metainfo_test_helper'
require_relative 'peer_test_helper'
require_relative 'peer_message_test_helper'
require_relative '../lib/kademlia/swarm'

describe Swarm do
  it "can be created with a torrent file" do
    s = Swarm.new(Metainfo.default_file)
  end

  it "can handle a HaveMessage" do
    s = Swarm.new(Metainfo.default_file)

    payload = PeerMessage.id_to_wire(4) + [0].pack("L>")
    have_message = PeerMessage.Create(5, payload)
    have_message.class.must_equal HaveMessage

    s.process_message(have_message, Peer.default)
  end
end
