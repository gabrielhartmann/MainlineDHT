class AsyncProducer
  def initialize(producer, queue)
    @prod_proc = producer
    @queue = queue
  end

  def generate
    @queue.push(@prod_proc.call)
  end

  def start
    @gen_thread = Thread.new do 
      loop do
	generate
      end
    end
  end

  def stop
    @gen_thread = nil
    @queue.clear
  end
end
