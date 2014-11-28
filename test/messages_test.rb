require_relative 'test_helper'
require_relative 'peer_message_test_helper'

describe PeerMessage do

  it "can create keep alive messages" do
    message = PeerMessage.Create
    message.class.must_equal KeepAliveMessage 
  end

  it "can create choke messages" do
    message = PeerMessage.Create(1, PeerMessage.id_to_wire(0))
    message.class.must_equal ChokeMessage
  end

  it "can create unchoke messages" do
    message = PeerMessage.Create(1, PeerMessage.id_to_wire(1))
    message.class.must_equal UnchokeMessage
  end

  it "can create interested messages" do
    message = PeerMessage.Create(1, PeerMessage.id_to_wire(2))
    message.class.must_equal InterestedMessage
  end

  it "can create not interested messages" do
    message = PeerMessage.Create(1, PeerMessage.id_to_wire(3))
    message.class.must_equal NotInterestedMessage
  end

  it "can create have messages" do
    payload = PeerMessage.id_to_wire(4) + [0].pack("L>")
    message = PeerMessage.Create(5, payload)
    message.class.must_equal HaveMessage
  end

  it "can create bitfield messages" do
    # simulating a payload for the bitfield of 0b00000011
    payload = PeerMessage.id_to_wire(5) + [3].pack("C")
    message = PeerMessage.Create(2, payload)
    message.class.must_equal BitfieldMessage
  end

  it "can create a request message" do
    payload = PeerMessage.id_to_wire(6) + [1, 1, 1].pack("L>L>L>")
    message = PeerMessage.Create(13, payload)
    message.class.must_equal RequestMessage
  end

  it "can create a piece message" do
    # A piece message has id 7 according to the spec
    id = 7
    index = beg = 1
    block = 5
    
    # Simulating a payload for a 1 byte block of 0b00000101
    sim_payload = [id, index, beg, block].pack("CL>L>C")

    # length is 10 because we have id + index + begin + block
    #                               1       4       4       1
    length = sim_payload.length
    length.must_equal 10

    message = PeerMessage.Create(length, sim_payload)
    message.class.must_equal PieceMessage
  end

  it "can create a cancel message" do
    payload = PeerMessage.id_to_wire(8) + [1, 1, 1].pack("L>L>L>")
    message = PeerMessage.Create(13, payload)
    message.class.must_equal CancelMessage
  end

  it "can create a port message" do
    payload = PeerMessage.id_to_wire(9) + [6881].pack("s>")
    message = PeerMessage.Create(3, payload)
    message.class.must_equal PortMessage 
  end
end
