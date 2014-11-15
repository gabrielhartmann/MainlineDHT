require_relative 'test_helper'
require_relative 'peer_test_helper'
require_relative '../lib/kademlia/peer_respond_state_machine'

describe PeerRespondStateMachine do

  it "must be able to transition from neutral to dont_respond and back" do
    # Initialization is as expected
    test_machine = PeerRespondStateMachine.new
    test_machine.neutral?.must_equal true
    test_machine.peer_interested.must_equal false 

    # Transition from neutral to dont_respond
    test_machine.can_recv_interested?.must_equal true
    test_machine.recv_interested!
    test_machine.dont_respond?.must_equal true
    test_machine.peer_interested.must_equal true

    # Transition from dont_respond to neutral
    test_machine.can_recv_not_interested?.must_equal true
    test_machine.recv_not_interested!
    test_machine.neutral?.must_equal true
    test_machine.peer_interested.must_equal false
  end 
  
end 
