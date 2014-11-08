require 'state_machine'

class PeerStateMachine
  def initialize(peer)
    @peer = peer
    super() # NOTE: This must be called, otherwise states won't get initialized
  end

  state_machine :state, :initial => :closed do
    event :shake do
      transition :closed => :shake_hands
    end

    event :ignite do
      transition :stalled => same, :parked => :idling
    end

  end
end
