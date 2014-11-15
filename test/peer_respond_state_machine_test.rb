require_relative 'test_helper'
require_relative 'peer_test_helper'
require_relative '../lib/kademlia/peer_respond_state_machine'

describe PeerRespondStateMachine do

  it "must be able to transition from neutral to wait_unchoke and back" do
    # Initialization is as expected
    test_machine = PeerRespondStateMachine.new
    test_machine.neutral?.must_equal true
    test_machine.peer_interested.must_equal false 

    # Transition from neutral to wait_unchoke
    test_machine.can_recv_interested?.must_equal true
    test_machine.recv_interested!
    test_machine.wait_unchoke?.must_equal true
    test_machine.peer_interested.must_equal true

    # Transition from wait_unchoke to neutral
    test_machine.can_recv_not_interested?.must_equal true
    test_machine.recv_not_interested!
    test_machine.neutral?.must_equal true
    test_machine.peer_interested.must_equal false
  end 

  it "must be able to transition from neutral to wait_unchoke to respond to wait_unchoke" do
    # Initialization is as expected
    test_machine = PeerRespondStateMachine.new
    test_machine.neutral?.must_equal true
    test_machine.peer_interested.must_equal false 

    # Transition from neutral to wait_unchoke
    test_machine.can_recv_interested?.must_equal true
    test_machine.recv_interested!
    test_machine.wait_unchoke?.must_equal true
    test_machine.peer_interested.must_equal true

    # Transition from wait_unchoke to respond
    test_machine.can_send_unchoke?.must_equal true 
    test_machine.send_unchoke!
    test_machine.respond?.must_equal true
    test_machine.am_choking.must_equal false

    # Transition from respond to wait_unchoke
    test_machine.can_send_choke?.must_equal true
    test_machine.send_choke!
    test_machine.wait_unchoke?.must_equal true
    test_machine.am_choking.must_equal true
  end
  
  it "must be able to transition from neutral to wait_unchoke to respond to wait_interest to respond" do
    # Initialization is as expected
    test_machine = PeerRespondStateMachine.new
    test_machine.neutral?.must_equal true
    test_machine.peer_interested.must_equal false 

    # Transition from neutral to wait_unchoke
    test_machine.can_recv_interested?.must_equal true
    test_machine.recv_interested!
    test_machine.wait_unchoke?.must_equal true
    test_machine.peer_interested.must_equal true

    # Transition from wait_unchoke to respond
    test_machine.can_send_unchoke?.must_equal true 
    test_machine.send_unchoke!
    test_machine.respond?.must_equal true
    test_machine.am_choking.must_equal false

    # Transition from respond to wait_interest
    test_machine.can_recv_not_interested?.must_equal true
    test_machine.recv_not_interested!
    test_machine.wait_interest?.must_equal true
    test_machine.peer_interested.must_equal false
    test_machine.can_recv_interested?.must_equal true
    test_machine.recv_interested!
    test_machine.respond?.must_equal true
    test_machine.peer_interested.must_equal true
  end

  it "must be able to transition from neutral to wait_interest to neutral" do
    # Initialization is as expected
    test_machine = PeerRespondStateMachine.new
    test_machine.neutral?.must_equal true
    test_machine.peer_interested.must_equal false 

    # Transition from neutral to wait_interest
    test_machine.can_send_unchoke?.must_equal true
    test_machine.send_unchoke!
    test_machine.wait_interest?.must_equal true
    test_machine.am_choking.must_equal false
    test_machine.peer_interested.must_equal false

    # Transition from wait_interest to neutral
    test_machine.can_send_choke?.must_equal true
    test_machine.send_choke!
    test_machine.neutral?.must_equal true
    test_machine.am_choking.must_equal true
    test_machine.peer_interested.must_equal false
  end
end 
