class AsyncProcessor
  attr_reader :queue

  def initialize (proc_func)
    @proc = proc_func
    @queue = Queue.new
  end

  def process(arg)
    @proc.call(arg)
  end

  def enqueue(arg)
    @queue.push(arg)
  end

  def start
    @proc_thread = Thread.new do 
      loop do
	process(@queue.pop)
      end
    end
  end
end
