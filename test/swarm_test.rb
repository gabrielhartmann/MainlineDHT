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

  it "can handle a BitfieldMessage" do
    s = Swarm.new(Metainfo.default_file)

    # simulating a payload for the bitfield of 0b00000011
    payload = PeerMessage.id_to_wire(5) + [3].pack("C")
    bitfield_message = PeerMessage.Create(2, payload)
    bitfield_message.class.must_equal BitfieldMessage

    s.process_message(bitfield_message, Peer.default)
  end
end
