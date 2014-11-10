require_relative 'test_helper'
require_relative '../lib/kademlia/messages'

describe PeerMessage do
  it "can create keep alive messages" do
    message = PeerMessage.Create
    message.class.must_equal KeepAliveMessage 
  end

  it "can create choke messages" do
    message = PeerMessage.Create(1, 0)
    message.class.must_equal ChokeMessage
  end

  it "can create unchoke messages" do
    message = PeerMessage.Create(1, 1)
    message.class.must_equal UnchokeMessage
  end

  it "can create interested messages" do
    message = PeerMessage.Create(1, 2)
    message.class.must_equal InterestedMessage
  end

  it "can create not interested messages" do
    message = PeerMessage.Create(1, 3)
    message.class.must_equal NotInterestedMessage
  end

  it "can create have messages" do
    message = PeerMessage.Create(5, 4, 0)
    message.class.must_equal HaveMessage
  end

  it "can create bitfield messages" do
    # simulating a payload for the bitfield of 0b00000011
    payload = [3].pack("C")
    message = PeerMessage.Create(2, 5, payload)
    message.class.must_equal BitfieldMessage
  end

  it "can create a request message" do
    payload = [1, 1, 1].pack("L>L>L>")
    message = PeerMessage.Create(13, 6, payload)
    message.class.must_equal RequestMessage
  end

  it "can create a piece message" do
    # A piece message has id 7 according to the spec
    id = 7
    index = beg = 1
    block = 5
    
    # Simulating a payload for a 1 byte block of 0b00000101
    sim_wire_message_without_length = [id, index, beg, block].pack("CL>L>C")
    only_payload = [index, beg, block].pack("L>L>C")

    # length is 10 because we have id + index + begin + block
    #                               1       4       4       1
    length = sim_wire_message_without_length.length
    length.must_equal 10

    message = PeerMessage.Create(length, id, only_payload)
    message.class.must_equal PieceMessage
  end

  it "can create a cancel message" do
    payload = [1, 1, 1].pack("L>L>L>")
    message = PeerMessage.Create(13, 8, payload)
    message.class.must_equal CancelMessage
  end

  it "can create a port message" do
    payload = [6881].pack("s>")
    message = PeerMessage.Create(3, 9, payload)
    message.class.must_equal PortMessage 
  end
end
