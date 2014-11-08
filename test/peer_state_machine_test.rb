require_relative 'test_helper'
require_relative 'peer_test_helper'
require_relative '../lib/kademlia/peer_state_machine'

describe PeerStateMachine do
  test_machine = PeerStateMachine.new(Peer.default)

  it "transition from closed to shake_hands on event shake" do
    test_machine.state.must_equal "closed"
    test_machine.shake
    test_machine.state.must_equal "shake_hands"
  end 

end 
