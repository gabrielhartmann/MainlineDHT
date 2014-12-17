require_relative 'test_helper'
require_relative '../lib/kademlia/krpc_messages'

describe KrpcMessage do
  it "can create a ping query" do
    msg = PingQueryMessage.new("ABCDEFGH")
  end
end
