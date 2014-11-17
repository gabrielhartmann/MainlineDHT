require 'workflow'
require_relative 'state_machine_errors'

class PeerSendStateMachine
  def initialize
    @am_interested = false
    @peer_choking = true
  end

  def am_interested?
    @am_interested
  end

  def peer_choking?
    @peer_choking
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

      on_entry do
        raise InvalidStateInvariant, "Am interested must be false." if am_interested?
        raise InvalidStateInvariant, "Peer choking must be true." unless peer_choking?
      end
    end

    state :wait_unchoke do
      event :send_not_interested, :transitions_to => :neutral
      event :recv_unchoke, :transitions_to => :send
      
      on_entry do
        raise InvalidStateInvariant, "Am interested must be true." unless am_interested?
        raise InvalidStateInvariant, "Peer choking must be true." unless peer_choking?
      end
    end

    state :send do
      event :recv_choke, :transitions_to => :wait_unchoke
      event :send_not_interested, :transitions_to => :wait_interest

      on_entry do
        raise InvalidStateInvariant, "Am interested must be true." unless am_interested?
        raise InvalidStateInvariant, "Peer choking must be false." if peer_choking?
      end
    end

    state :wait_interest do
      event :send_interested, :transitions_to => :send
      event :recv_choke, :transitions_to => :neutral

      on_entry do
        raise InvalidStateInvariant, "Am interested must be false." if am_interested?
        raise InvalidStateInvariant, "Peer choking must be false." if peer_choking?
      end
    end

    on_transition do |from, to, triggering_event, *event_args|
     # puts "#{triggering_event}: #{from} -> #{to}"
    end
  end
end 
