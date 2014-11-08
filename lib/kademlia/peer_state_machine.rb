require 'state_machine'

class Peer
  state_machine :state, :initial => :closed do
    event :shake do
      transition :closed => :shake_hands
    end
  end
end
