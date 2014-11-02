require_relative 'message_errors'

class PeerMessage
  attr_reader :length
  attr_reader :id

  def initialize(length, id)
    @length = length
    @id = id
  end

  def self.Create(length=0, id=nil, payload=nil)
    case length
    when 0
      return KeepAliveMessage.new if length == 0
    when 1
      raise MessageError, "Messages of length #{length} must not have a payload" if payload != nil
      CreateChokeInterestMessage(id)
    when 2..Float::INFINITY
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
  def initialize(piece_index)
    raise MessageError, "Invalid piece index: #{piece_index}" unless piece_index >= 0
    super(5, 4, piece_index)
  end
end

class BitfieldMessage < PayloadMessage
  def initialize(length, bitfield)
    raise MessageError, "A bitfield message must have a length of at least 2, not #{length}" if length < 2 
    super(length, 5, bitfield)
  end
end

class RequestMessage < PayloadMessage
  attr_reader :index
  attr_reader :begin
  attr_reader :length

  def initialize(payload)
    super(13, 6, payload)
    @index, @begin, @length = payload.unpack("L>L>L>")
  end
end


class PieceMessage < PayloadMessage
  attr_reader :index
  attr_reader :begin
  attr_reader :block
    
  def initialize(length, payload)
    super(length, 7, payload)
    @index, @begin, @block = payload.unpack("L>L>C")
  end
end

class CancelMessage < PayloadMessage
  attr_reader :index
  attr_reader :begin
  attr_reader :length

  def initialize(payload)
    super(13, 8, payload)
    @index, @begin, @length = payload.unpack("L>L>L>")
  end
end

class PortMessage < PayloadMessage
  def initialize(payload)
    super(3, 9, payload)
  end
end
