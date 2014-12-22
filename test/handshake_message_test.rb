require_relative 'test_helper'
require_relative '../lib/kademlia/messages'

describe HandshakeMessage do

  it "can create a handshake which indicates support of DHT" do
    msg = HandshakeMessage.new
    puts msg.inspect
    raise StandardError, "Test not implemented"
  end

end
