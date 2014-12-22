require 'socket'

class NodeSocket
  def initialize
    @socket = UDPSocket.new
    bind_result = @socket.bind(Socket::INADDR_ANY, 0)
    puts bind_result.inspect
  end

  def self.open
    NodeSocket.new
  end

  def address
    @socket.addr
  end

  def read
    @socket.recvfrom(1024) # if this number is too low it will drop the larger packets and never give them to you
  end
end
