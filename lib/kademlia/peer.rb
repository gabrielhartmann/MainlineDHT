require 'socket'
require_relative 'peer_errors'
require_relative 'handshake_response'

class Peer
  attr_accessor :id

  def initialize(ip, port, hashed_info, local_peer_id, id = generate_id)
    raise InvalidPeerError, "Peer ids must be 20 characters long." unless id.length == 20

    @ip = ip
    @id = id
    @port = port
    @hashed_info = hashed_info
    @local_peer_id = local_peer_id
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

    return HandShakeResponse.new(length, protocol, reserved, info_hash, peer_id)
  end
  

private

  def generate_id
    (0...20).map { ('a'..'z').to_a[rand(26)] }.join
  end

end
