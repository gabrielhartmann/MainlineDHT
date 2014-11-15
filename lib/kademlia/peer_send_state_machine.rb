require 'workflow'
require_relative 'peer'

class PeerSendStateMachine
  attr_reader :am_interested
  attr_reader :peer_choking

  def initialize
    @am_interested = false
    @peer_choking = true
  end

  def recv_choke
    @peer_choking = true
  end

  def recv_unchoke
    @peer_choking = false
  end

  def send_interested
    @am_interested = true
  end

  def send_not_interested
    @am_interested = false
  end

  include Workflow
  workflow do
    state :neutral do
      event :send_interested, :transitions_to => :wait_unchoke
      event :recv_unchoke, :transitions_to => :wait_interest
    end

    state :wait_unchoke do
      event :send_not_interested, :transitions_to => :neutral
      event :recv_unchoke, :transitions_to => :send
    end

    state :send do
      event :recv_choke, :transitions_to => :wait_unchoke
      event :send_not_interested, :transitions_to => :wait_interest
    end

    state :wait_interest do
      event :send_interested, :transitions_to => :send
      event :recv_choke, :transitions_to => :neutral
    end

    on_transition do |from, to, triggering_event, *event_args|
     # puts "#{triggering_event}: #{from} -> #{to}"
    end
  end
end 
