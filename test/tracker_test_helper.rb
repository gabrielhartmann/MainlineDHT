require_relative 'metainfo_test_helper'
require_relative '../lib/kademlia/tracker'

class Tracker
  @@default_tracker = nil

  def self.default
    if (!@@default_tracker)
      @@default_tracker = Tracker.new(Metainfo.default)
    end

    return @@default_tracker
  end
end
