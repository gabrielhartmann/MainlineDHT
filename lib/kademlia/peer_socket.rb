require 'socket'
require_relative 'handshake_response'
require_relative 'messages'
require_relative 'peer_protocol_errors'

class PeerSocket
  def initialize(peer)
    @peer = peer 
  end

  def self.open(peer)
    PeerSocket.new(peer)
  end

  def close
    @socket.close if @socket
  end

  def shake_hands
    begin
      @socket = TCPSocket.open(@peer.ip, @peer.port)
      reserved = "\0\0\0\0\0\0\0\1"
      handshake_request = HandshakeMessage.new(reserved, @peer.hashed_info, @peer.local_peer_id)
      write(handshake_request)

      length = @socket.read(1)[0]
      protocol = @socket.read(19)
      reserved = @socket.read(8)
      info_hash = @socket.read(20)
      peer_id = @socket.read(20)

      HandShakeResponse.new(length, protocol, reserved, info_hash, peer_id)

    rescue Exception => e
      raise PeerProtocolError, "Failed to shake hands with exception: #{e}"
    end
  end

  def read
    length = @socket.read(4).unpack("L>").first
    raise PeerProtocolError, "Invalid message length." unless length >= 0

    if (length > 0)
      payload = @socket.read(length)
    end

    return PeerMessage.Create(length, payload)
  end

  def write(message)
    @socket.write(message.to_wire)
  end
end
