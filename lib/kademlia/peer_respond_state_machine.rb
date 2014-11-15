require 'workflow'
require_relative 'peer'

class PeerRespondStateMachine
  attr_reader :am_chocking
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
    @am_chocking = true
  end

  def send_unchoke
    @am_chocking = false
  end

  include Workflow
  workflow do
    state :neutral do
      event :recv_interested, :transitions_to => :dont_respond
    end

    state :dont_respond do
      event :recv_not_interested, :transitions_to => :neutral
      event :send_unchoke, :transitions_to => :respond

      after_transition do
	# pass through this state if we are already unchoked
	send_unchoke! unless @am_choking
      end
    end

    state :respond do
      event :send_choke, :transitions_to => :dont_respond
      event :recv_not_interested, :transitions_to => :neutral
    end

    on_transition do |from, to, triggering_event, *event_args|
      # puts "#{triggering_event}: #{from} -> #{to}"
    end
  end
end 
