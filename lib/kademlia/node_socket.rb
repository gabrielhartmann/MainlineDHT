require 'socket'

class NodeSocket
  def initialize(logger, ip, port)
    @logger = logger
    @ip = ip
    @port = port
    @socket = UDPSocket.new
    @socket.connect(@ip, @port)
  end

  def address
    "#{@ip}:#{@port}"
  end

  def read
    msg = @socket.recvfrom(1024) # if this number is too low it will drop the larger packets and never give them to you
    @logger.debug "#{address} Node read: #{msg}"
    return msg
  end

  def write(msg)
    @logger.debug "#{address} Node writing: #{msg} on wire as #{msg.to_wire}"
    @socket.send(msg.to_wire, 0)
  end
end
