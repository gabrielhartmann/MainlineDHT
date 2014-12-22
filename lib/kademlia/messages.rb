require_relative 'message_errors'

class HandshakeMessage
  @@protocol_name = "BitTorrent protocol"

  def initialize(reserved, hashed_info, peer_id)
    @reserved = reserved
    @hashed_info = hashed_info
    @peer_id = peer_id
  end

  def to_wire
    protocol_length = [@@protocol_name.length].pack("C")
    msg = protocol_length + @@protocol_name + @reserved + @hashed_info + @peer_id
    return msg
  end
end

class PeerMessage
  attr_reader :length
  attr_reader :id

  def initialize(length, id)
    @length = length
    @id = id
  end
  
  def self.id_to_wire(id)
    [id].pack("C")
  end

  def to_wire
    length = [@length].pack("L>")
    id = PeerMessage.id_to_wire(@id) if @id
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
      CreatePayloadMessage(id, payload)
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

  def self.CreatePayloadMessage(id, payload)
    case id
    when 4
      HaveMessage.new(payload)
    when 5
      BitfieldMessage.new(payload)
    when 6
      RequestMessage.new(payload)
    when 7
      PieceMessage.new(payload)
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
    peer_wire_message = super
    wire_message = peer_wire_message + payload
  end
end

class BlockMessage < PayloadMessage
  attr_reader :index
  attr_reader :begin
  attr_reader :length

  def initialize(id, payload)
    raise MessageError, "Block messages must have a length of 13, not #{payload.length + 1}" if payload.length + 1 != 13
    super(payload.length + 1, id, payload)
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

  @@message_id = 4

  def initialize(payload)
    raise MessageError, "Have messages must have a length of 5, not #{payload.length + 1}" if payload.length + 1 != 5
    super(payload.length + 1, @@message_id, payload)
    @piece_index = @payload.unpack("L>").first
    raise MessageError, "Invalid piece index: #{@piece_index}" unless @piece_index >= 0
  end

  def self.Create(index)
    payload = [index].pack("L>")
    return HaveMessage.new(payload)
  end
end

class BitfieldMessage < PayloadMessage
  def initialize(payload)
    raise MessageError, "A bitfield message must have a length of at least 2, not #{payload.length + 1}" if payload.length + 1 < 2 
    super(payload.length+1, 5, payload)
  end

  # bitfield string should be a string like "0001101010101"
  def self.Create(bitfield_string)
    payload = [bitfield_string].pack("B*")
    return BitfieldMessage.new(payload)
  end

  def to_s
    "Bitfield: #{@payload.unpack("B*").first}"
  end
end

class RequestMessage < BlockMessage
  def initialize(payload)
    super(6, payload)
  end

  def self.create(index, offset, length)
    RequestMessage.new([index, offset, length].pack("L>L>L>"))
  end
end

class PieceMessage < PayloadMessage
  attr_reader :index
  attr_reader :begin
  attr_reader :block
    
  def initialize(payload)
    super(payload.length+1, 7, payload)
    # unpack the whole message
    unpacked_payload = payload.unpack("L>L>C*")

    # extract the piece index and offset in the piece
    @index = unpacked_payload[0]
    @begin = unpacked_payload[1]

    # re-pack the actual piece
    @block = unpacked_payload[2..-1].pack("C*")
  end

  def self.get_payload(idx, bgn, block)
    [idx, bgn, block.bytes].flatten.pack("L>L>C*")
  end

  def self.Create(idx, bgn, block)
    return PieceMessage.new(PieceMessage.get_payload(idx, bgn, block))
  end
end

class CancelMessage < BlockMessage
  def initialize(payload)
    super(8, payload)
  end
end

class PortMessage < PayloadMessage
  def initialize(payload)
    raise MessageError, "Payload length must be 2 for a PortMessage, not #{payload.length}" if payload.length != 2
    super(3, 9, payload)
  end

  def self.create(port)
    return PortMessage.new([port].pack("S>"))
  end
end
