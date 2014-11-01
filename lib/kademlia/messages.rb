require_relative 'message_errors'

class PeerMessage
  attr_reader :length
  attr_reader :id

  def initialize(length, id)
    @length = length
    @id = id
  end

  def self.CreateMessage(length, id, payload=nil)

  end
end

class PayloadMessage < PeerMessage
  attr_reader :payload

  def initialize(length, id, payload)
    super(length, id)
    @payload = payload
  end
end

class KeepAliveMessage < PeerMessage
  def initialize
    super(0, nil)
  end
end


