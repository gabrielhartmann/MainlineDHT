require 'bencode'

class KrpcMessage
  attr_reader :hash

  def initialize(transaction_id)
    @hash = Hash.new
    @hash["t"] = transaction_id
  end

  def to_wire
    bencode
  end
  
  def bencode
    @hash.bencode
  end

private

  def generate_id
    Random.new().bytes(2).to_s
  end
end

class QueryMessage < KrpcMessage
  def initialize(transaction_id)
    super(transaction_id)
    @hash["y"] = "q"
  end
end

class ResponseMessage < KrpcMessage
  def initialize(transaction_id)
    super(transaction_id)
    @hash["y"] = "r"
  end
end

class PingQueryMessage < QueryMessage
  def initialize(node_id)
    super(generate_id)
    @hash["q"] = "ping"
    @hash["a"] = {"id" => node_id.to_s}
  end
end

class PingResponseMessage < ResponseMessage
  def initialize(node_id)
    super(generate_id)
    @hash["r"] = {"id" => node_id.to_s}
  end
end
