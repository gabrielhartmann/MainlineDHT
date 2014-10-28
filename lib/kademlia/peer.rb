require 'socket'
require_relative 'peer_errors'
require_relative 'handshake_response'

class Peer
  attr_accessor :id
  
  attr_accessor :am_choking
  attr_accessor :am_interested
  attr_accessor :peer_choking
  attr_accessor :peer_interested


  @@dht_bitmask = 0x0000000000000001

  def initialize(ip, port, hashed_info, local_peer_id, id = generate_id)
    @ip = ip
    @id = set_id(id)
    @port = port
    @hashed_info = hashed_info
    @local_peer_id = local_peer_id
  end

  def to_s
    "ip: #{@ip} port: #{@port} id: #{@id} hashed_info: #{@hashed_info} local_peer_id: #{@local_peer_id} handshake_response: #{@handshake_response}"
  end

  def supports_dht?
    raise InvalidPeerError, "Cannot determine DHT support without a hand shake." unless @handshake_response
    (@handshake_response.reserved & @@dht_bitmask) != 0
  end

  def shake_hands
    s = TCPSocket.open(@ip, @port)
    s.send("\023BitTorrent protocol\0\0\0\0\0\0\0\0", 0);
    s.send("#{@hashed_info}#{@local_peer_id}", 0)

    length = s.recv(1)[0]
    protocol = s.recv(19)
    reserved = s.recv(8)
    info_hash = s.recv(20)
    peer_id = s.recv(20)

    s.close

    @handshake_response = HandShakeResponse.new(length, protocol, reserved, info_hash, peer_id)
    set_id(@handshake_response.peer_id)

    return @handshake_response
  end


  

private

  def generate_id
    (0...20).map { ('a'..'z').to_a[rand(26)] }.join
  end

  def set_id(id)
    raise InvalidPeerError, "Peer ids must be 20 characters long." unless id.length == 20
    @id = id
  end

end
