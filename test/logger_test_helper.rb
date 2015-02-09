require 'mono_logger'
require_relative 'metainfo_test_helper'
require_relative '../lib/kademlia/swarm'

class Logger
  @@default_logger = nil

  def self.default
    if (!@@default_logger)
      @@default_logger = MonoLogger.new('test.log', 10, 1024000)
    end

    return @@default_logger
  end
end
