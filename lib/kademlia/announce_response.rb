require 'bencode'

class AnnounceResponse
  attr_reader :complete
  attr_reader :incomplete
  attr_reader :interval
  attr_reader :peers

  def initialize(response)
    decoded_response = BEncode.load(response)
    @complete = decoded_response['complete']
    @incomplete = decoded_response['incomplete']
    @interval = decoded_response['interval']
    @peers = decode_peers(decoded_response['peers'])
#    @peers = decoded_response['peers']
  end

  def decode_peers(encoded_peers)
    peers = Array.new
    index = 0
    while index + 6 <= encoded_peers.length
      ip = encoded_peers[index,4].unpack("CCCC").join('.')
      port = encoded_peers[index+4,2].unpack("n").first

      # -1 for the peer_id indicates an invalid id.  We don't
      # yet know the real id
      peers.push Node.new(-1, ip, port)
      index += 6
    end

    return peers
  end

end
