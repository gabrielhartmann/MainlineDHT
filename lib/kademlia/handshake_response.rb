class HandShakeResponse
  attr_reader :length
  attr_reader :protocol
  attr_reader :reserved
  attr_reader :info_hash
  attr_reader :peer_id

  def initialize (length, protocol, reserved, info_hash, peer_id)
    @length = length
    @protocol = protocol
    @reserved = reserved
    @info_hash = info_hash
    @peer_id = peer_id
  end

end
