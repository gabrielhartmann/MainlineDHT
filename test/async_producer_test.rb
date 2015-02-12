require 'timeout'
require_relative 'test_helper'
require_relative '../lib/kademlia/async_producer'

describe AsyncProducer do
  it "can be created with a producing function and a queue" do
    producer = AsyncProducer.new(Proc.new {}, Queue.new)
  end

  it "can put elements in a queue" do
    prod_proc = Proc.new {1}
    queue = Queue.new
    producer = AsyncProducer.new(prod_proc, queue)
    10.times do
      producer.generate
    end 
    
    queue.length.must_equal 10
  end

  it "can start producing elements asynchronously" do
    prod_proc = Proc.new {1}
    queue = Queue.new
    producer = AsyncProducer.new(prod_proc, queue)
    producer.start

    Timeout::timeout(5) do
      loop do
        break if (queue.length > 0)
      end
    end

    producer.stop
    queue.length.must_equal 0
  end
end
