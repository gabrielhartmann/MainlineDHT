require 'timeout'
require_relative 'test_helper'
require_relative '../lib/kademlia/async_processor'

describe AsyncProcessor do
  it "can be created with a processing function" do
    processor = AsyncProcessor.new(Proc.new {})
  end

  it "can process work with external side effects" do
    effect = 0
    processor = AsyncProcessor.new(Proc.new {|arg| effect = arg })
    processor.process(2)
    effect.must_equal 2
  end

  it "can enqueue work to be processed later" do
    effect = 0
    processor = AsyncProcessor.new(Proc.new {|arg| effect += arg })
    processor.push(1)
    processor.push(2)
    processor.push(3)
    processor.push(4)
    processor.start

    Timeout::timeout(5) do
      loop do
	break if effect == 10 
      end
    end
  end
end
