require_relative 'message_errors'

class PeerMessage
  attr_reader :length
  attr_reader :id

  def initialize(length, id)
    @length = length
    @id = id
  end

  def to_wire
    length = [@length].pack("L>")
    id = [@id].pack("C") if @id
    wire_message = length + id
  end

  def self.Create(length=0, payload=nil)
    if (payload)
      raise MessageError, "Payload length must be greater than 0, not #{payload.length}" if payload.length < 1
      id = payload[0].unpack("C").first
    end

    case length
    when 0
      return KeepAliveMessage.new
    when 1
      CreateChokeInterestMessage(id)
    when 2..Float::INFINITY
      payload = payload[1..payload.length-1]
      CreatePayloadMessage(length, id, payload)
    else
      raise MessageError, "Invalid message length: #{length}"
    end 
  end

  def self.CreateChokeInterestMessage(id)
    return MessageError, "All choke or interest messages have an id" if id == nil
    case id
    when 0
      ChokeMessage.new
    when 1
      UnchokeMessage.new
    when 2
      InterestedMessage.new
    when 3
      NotInterestedMessage.new
    else
      raise MessageError, "Unsupported choke interest message id: #{id} encountered."
    end
  end

  def self.CreatePayloadMessage(length, id, payload)
    case id
    when 4
      raise MessageError, "Have messages must have a length of 5, not #{length}" if length != 5
      HaveMessage.new(payload)
    when 5
      BitfieldMessage.new(length, payload)
    when 6
      RequestMessage.new(payload)
    when 7
      PieceMessage.new(length, payload)
    when 8
      CancelMessage.new(payload)
    when 9
      PortMessage.new(payload)
    else
      raise MessageError, "Unknown payload message id: #{id}"
    end
  end
end

class PayloadMessage < PeerMessage
  attr_reader :payload

  def initialize(length, id, payload)
    super(length, id)
    @payload = payload
  end

  def to_wire
    peer_wire_message = super.to_wire
    wire_message = peer_wire_message + payload
  end
end

class BlockMessage < PayloadMessage
  attr_reader :index
  attr_reader :begin
  attr_reader :length

  def initialize(id, payload)
    super(13, id, payload)
    @index, @begin, @length = payload.unpack("L>L>L>")
  end
end

class KeepAliveMessage < PeerMessage
  def initialize
    super(0, nil)
  end
end

class ChokeMessage < PeerMessage
  def initialize
    super(1, 0)
  end
end

class UnchokeMessage < PeerMessage
  def initialize
    super(1, 1)
  end
end

class InterestedMessage < PeerMessage
  def initialize
    super(1, 2)
  end
end

class NotInterestedMessage < PeerMessage
  def initialize
    super(1, 3)
  end
end

class HaveMessage < PayloadMessage
  attr_reader :piece_index
  def initialize(payload)
    super(5, 4, payload)
    @piece_index = @payload.unpack("L>").first
    raise MessageError, "Invalid piece index: #{@piece_index}" unless @piece_index >= 0
  end
end

class BitfieldMessage < PayloadMessage
  def initialize(length, payload)
    super(length, 5, payload)
    raise MessageError, "A bitfield message must have a length of at least 2, not #{length}" if length < 2 
  end
end

class RequestMessage < BlockMessage
  def initialize(payload)
    super(6, payload)
  end
end

class PieceMessage < PayloadMessage
  attr_reader :index
  attr_reader :begin
  attr_reader :block
    
  def initialize(length, payload)
    super(length, 7, payload)
    @index, @begin, @block = payload.unpack("L>L>C*")
  end
end

class CancelMessage < BlockMessage
  def initialize(payload)
    super(8, payload)
  end
end

class PortMessage < PayloadMessage
  def initialize(payload)
    super(3, 9, payload)
  end
end
