require 'workflow'
require_relative 'state_machine_errors'
require_relative 'messages'

class PeerRespondStateMachine
  def initialize(peer)
    @peer = peer
    @logger = peer.logger
    @ip = peer.ip
    @port = peer.port
    @am_choking = true
    @peer_interested = false
  end

  def am_choking?
    @am_choking
  end

  def peer_interested?
    @peer_interested
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
      event :eval_unchoke, :transitions_to => :neutral

      on_entry do
        raise InvalidStateInvariant, "Am choking must be true." unless am_choking?
        raise InvalidStateInvariant, "Peer interested must be false." if peer_interested?

	if (@peer.should_unchoke?)
	  @peer.write(UnchokeMessage.new)
	end
      end
    end

    state :wait_unchoke do
      event :recv_not_interested, :transitions_to => :neutral
      event :send_unchoke, :transitions_to => :respond
      event :eval_unchoke, :transitions_to => :wait_unchoke

      on_entry do
        raise InvalidStateInvariant, "Am choking must be true." unless am_choking?
        raise InvalidStateInvariant, "Peer interested must be true." unless peer_interested?

	if (@peer.should_unchoke?)
	  @peer.write(UnchokeMessage.new)
	end
      end
    end

    state :respond do
      event :send_choke, :transitions_to => :wait_unchoke
      event :recv_not_interested, :transitions_to => :wait_interest
      event :eval_unchoke, :transitions_to => :respond

      on_entry do
	raise InvalidStateInvariant, "Am choking must be false." if am_choking?
	raise InvalidStateInvariant, "Peer interested must be true." unless peer_interested?

	unless (@peer.should_unchoke?)
	  @peer.write(ChokeMessage.new)
	end
      end
    end

    state :wait_interest do
      event :recv_interested, :transitions_to => :respond
      event :send_choke, :transitions_to => :neutral
      event :eval_unchoke, :transitions_to => :wait_interest

      on_entry do
	raise InvalidStateInvariant, "Am choking must be false." if am_choking?
	raise InvalidStateInvariant, "Peer interested must be false." if peer_interested?

	unless (@peer.should_unchoke?)
	  @peer.write(ChokeMessage.new)
	end
      end
    end

    on_transition do |from, to, triggering_event, *event_args|
      @logger.debug "#{@ip}:#{@port} RST: #{triggering_event}: #{from} -> #{to}"
    end
  end
end 
