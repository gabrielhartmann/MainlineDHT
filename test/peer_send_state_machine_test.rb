require_relative 'test_helper'
require_relative 'peer_test_helper'
require_relative '../lib/kademlia/peer_send_state_machine'

describe PeerSendStateMachine do
  def get_random_peer
    p = Peer.random
    p.join(Swarm.default)
    return p
  end

  it "must be able to transition from neutral to wait_unchoke and back" do
    # Initialization is as expected
    test_machine = PeerSendStateMachine.new(get_random_peer)
    test_machine.neutral?.must_equal true

    # Transition from neutral to wait_unchoke
    test_machine.can_send_interested?.must_equal true
    test_machine.send_interested!
    test_machine.wait_unchoke?.must_equal true

    # Transition from wait_unchoke to neutral
    test_machine.can_send_not_interested?.must_equal true
    test_machine.send_not_interested!
    test_machine.neutral?.must_equal true
  end 

  it "must be able to transition from neutral to wait_unchoke to send to wait_unchoke" do
    # Initialization is as expected
    test_machine = PeerSendStateMachine.new(get_random_peer)
    test_machine.neutral?.must_equal true

    # Transition from neutral to wait_unchoke
    test_machine.can_send_interested?.must_equal true
    test_machine.send_interested!
    test_machine.wait_unchoke?.must_equal true

    # Transition from wait_unchoke to send
    test_machine.can_recv_unchoke?.must_equal true 
    test_machine.recv_unchoke!
    test_machine.send?.must_equal true

    # Transition from send to wait_unchoke
    test_machine.can_recv_choke?.must_equal true
    test_machine.recv_choke!
    test_machine.wait_unchoke?.must_equal true
  end
  
  it "must be able to transition from neutral to wait_unchoke to send to wait_interest to send" do
    # Initialization is as expected
    test_machine = PeerSendStateMachine.new(get_random_peer)
    test_machine.neutral?.must_equal true

    # Transition from neutral to wait_unchoke
    test_machine.can_send_interested?.must_equal true
    test_machine.send_interested!
    test_machine.wait_unchoke?.must_equal true

    # Transition from wait_unchoke to send
    test_machine.can_recv_unchoke?.must_equal true 
    test_machine.recv_unchoke!
    test_machine.send?.must_equal true

    # Transition from send to wait_interest
    test_machine.can_send_not_interested?.must_equal true
    test_machine.send_not_interested!
    test_machine.wait_interest?.must_equal true
    
    # Transition from wait_interest to send 
    test_machine.can_send_interested?.must_equal true
    test_machine.send_interested!
    test_machine.send?.must_equal true
  end

  it "must be able to transition from neutral to wait_interest to neutral" do
    # Initialization is as expected
    test_machine = PeerSendStateMachine.new(get_random_peer)
    test_machine.neutral?.must_equal true

    # Transition from neutral to wait_interest
    test_machine.can_recv_unchoke?.must_equal true
    test_machine.recv_unchoke!
    test_machine.wait_interest?.must_equal true

    # Transition from wait_interest to neutral
    test_machine.can_recv_choke?.must_equal true
    test_machine.recv_choke!
    test_machine.neutral?.must_equal true
  end
end 
