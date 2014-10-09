class Node
  attr_reader :peer_id
  attr_reader :ip
  attr_reader :port

  def initialize (peer_id, ip, port)
    @peer_id = peer_id
    @ip = ip
    @port = port
  end
end
