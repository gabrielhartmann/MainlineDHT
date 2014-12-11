require_relative 'metainfo_test_helper'
require_relative 'logger_test_helper'
require_relative '../lib/kademlia/tracker'

class Tracker
  @@default_tracker = nil

  def self.default
    if (!@@default_tracker)
      @@default_tracker = Tracker.new(Logger.default, Metainfo.default)
    end

    return @@default_tracker
  end
end
