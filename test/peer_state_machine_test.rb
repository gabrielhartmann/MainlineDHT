require_relative 'test_helper'
require_relative 'peer_test_helper'
require_relative '../lib/kademlia/peer_state_machine'

describe PeerStateMachine do

  it "must be able to transition from closed to shake_hands on event shake" do
    test_machine = PeerStateMachine.new(Peer.default)
    test_machine.closed?.must_equal true
    test_machine.can_shake?.must_equal true
    test_machine.shake!
    test_machine.shake_hands?.must_equal true
  end 
  
  it "must be able to transition from closed to closed on event error" do
    test_machine = PeerStateMachine.new(Peer.default)
    test_machine.closed?.must_equal true
    test_machine.can_error?.must_equal true
    test_machine.error!
    test_machine.closed?.must_equal true
  end 

  it "must be able to transition from closed to shake_hands to closed" do
    test_machine = PeerStateMachine.new(Peer.default)
    test_machine.closed?.must_equal true
    test_machine.can_shake?.must_equal true
    test_machine.shake!
    test_machine.shake_hands?.must_equal true
    test_machine.can_error?.must_equal true
    test_machine.error!
    test_machine.closed?.must_equal true
  end

  #it "debug" do
  #  puts "Number of peers = #{Peer.default_peers.length}"
  #  Peer.default_peers.each do |peer|
  #    puts peer.class
  #    machine = PeerStateMachine.new(peer)
  #    machine.shake!
  #  end
  #end
end 
