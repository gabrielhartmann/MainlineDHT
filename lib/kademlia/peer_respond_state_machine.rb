require 'workflow'
require_relative 'peer'

class PeerRespondStateMachine
  attr_reader :am_choking
  attr_reader :peer_interested

  def initialize
    @am_choking = true
    @peer_interested = false
  end

  def recv_interested
    @peer_interested = true
  end

  def recv_not_interested
    @peer_interested = false
  end

  def send_choke
    @am_choking = true
  end

  def send_unchoke
    @am_choking = false
  end

  include Workflow
  workflow do
    state :neutral do
      event :recv_interested, :transitions_to => :wait_unchoke
      event :send_unchoke, :transitions_to => :wait_interest
    end

    state :wait_unchoke do
      event :recv_not_interested, :transitions_to => :neutral
      event :send_unchoke, :transitions_to => :respond
    end

    state :respond do
      event :send_choke, :transitions_to => :wait_unchoke
      event :recv_not_interested, :transitions_to => :wait_interest
    end

    state :wait_interest do
      event :recv_interested, :transitions_to => :respond
      event :send_choke, :transitions_to => :neutral
    end

    on_transition do |from, to, triggering_event, *event_args|
     # puts "#{triggering_event}: #{from} -> #{to}"
    end
  end
end 
