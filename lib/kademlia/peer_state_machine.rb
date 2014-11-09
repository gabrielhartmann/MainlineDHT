require 'workflow'
require_relative 'peer'

class PeerStateMachine
  attr_reader :peer

  def initialize(peer)
    @peer = peer
  end
  
  def call_with_error_handling 
    begin
      yield
    rescue StandardError => e
      puts e.inspect
      error!
    rescue Exception => e
      puts e.inspect
      error!
    end
  end

  include Workflow
  workflow do
    state :closed do
      event :error, :transitions_to => :closed
      event :shake, :transitions_to => :shake_hands
    end
    
    state :shake_hands do
      event :error, :transitions_to => :closed

      on_entry do
	call_with_error_handling { @peer.shake_hands }
      end
    end



    on_transition do |from, to, triggering_event, *event_args|
      # puts "#{from} -> #{to}"
    end
  end
end
