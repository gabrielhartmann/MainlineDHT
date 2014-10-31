require 'socket'
require_relative 'peer_errors'
require_relative 'handshake_response'
require_relative 'messages'

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
    @socket = TCPSocket.open(@ip, @port)
  end

  def to_s
    "ip: #{@ip} port: #{@port} id: #{@id} hashed_info: #{@hashed_info} local_peer_id: #{@local_peer_id} handshake_response: #{@handshake_response}"
  end

  def supports_dht?
    raise InvalidPeerError, "Cannot determine DHT support without a hand shake." unless @handshake_response
    (@handshake_response.reserved & @@dht_bitmask) != 0
  end

  def shake_hands
    @socket.send("\023BitTorrent protocol\0\0\0\0\0\0\0\0", 0);
    @socket.send("#{@hashed_info}#{@local_peer_id}", 0)

    length = @socket.recv(1)[0]
    protocol = @socket.recv(19)
    reserved = @socket.recv(8)
    info_hash = @socket.recv(20)
    peer_id = @socket.recv(20)

    @handshake_response = HandShakeResponse.new(length, protocol, reserved, info_hash, peer_id)
    set_id(@handshake_response.peer_id)

    return @handshake_response
  end

  def read_next_message
    length = @socket.read(4).unpack("L>").first
    raise PeerProtocolError, "Invalid message length." unless length >= 0
    
    if (length == 0)
      return KeepAliveMessage.new
    else
      id = @socket.read(1).unpack("C").first

      message = PeerMessage.new(length, id)
      puts "message.id = #{message.id}"
      puts "message.length = #{message.length}"

      if (message.length > 1)
	payload = @socket.read(message.length - 1)
	message = PayloadMessage.new(length, id, payload)
	puts "message.id = #{message.id}"
	puts "message.length = #{message.length}"
	puts "message.payload = #{message.payload.inspect}"
      end


    end

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
