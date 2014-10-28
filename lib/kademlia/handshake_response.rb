class HandShakeResponse
  attr_reader :length
  attr_reader :protocol
  attr_reader :reserved
  attr_reader :info_hash
  attr_reader :peer_id

  def initialize (length, protocol, reserved, info_hash, peer_id)
    # Unpacking noter:  All unpacking returns an array.  In most cases we expect
    # a single element array so we return the first entry. 

    # Unpack a single byte as an unsigned integer.
    @length = length.unpack('C').first
    @protocol = protocol

    # Unpack 8 bytes as 64 bit Integer Big Endian. 
    @reserved = reserved.unpack('Q>').first
    @info_hash = info_hash
    @peer_id = peer_id
  end

  def to_s
    "length: #{@length.inspect} protocol: #{@protocol} reserved: #{@reserved.inspect} info_hash: #{@info_hash.inspect} peer_id: #{@peer_id.inspect}"
  end

end
