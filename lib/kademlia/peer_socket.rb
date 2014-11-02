require 'socket'
require_relative 'handshake_response'

class PeerSocket
  def initialize(peer)
    @peer = peer
  end

  def shake_hands
    s = TCPSocket.open(@peer.ip, @peer.port)

    s.send("\023BitTorrent protocol\0\0\0\0\0\0\0\0", 0);
    s.send("#{@peer.hashed_info}#{@peer.local_peer_id}", 0)

    length = s.recv(1)[0]
    protocol = s.recv(19)
    reserved = s.recv(8)
    info_hash = s.recv(20)
    peer_id = s.recv(20)

    s.close

    HandShakeResponse.new(length, protocol, reserved, info_hash, peer_id)
  end
end
