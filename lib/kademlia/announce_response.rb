require 'bencode'

class AnnounceResponse
  attr_reader :complete
  attr_reader :incomplete
  attr_reader :interval
  attr_reader :peers

  def initialize(response, hashed_info, local_peer_id)
    decoded_response = BEncode.load(response)
    @hashed_info = hashed_info
    @local_peer_id = local_peer_id
    @complete = decoded_response['complete']
    @incomplete = decoded_response['incomplete']
    @interval = decoded_response['interval']
    @peers = decode_peers(decoded_response['peers'])
  end

private

  def decode_peers(encoded_peers)
    peers = Array.new
    index = 0
    while index + 6 <= encoded_peers.length
      ip = encoded_peers[index,4].unpack("CCCC").join('.')
      port = encoded_peers[index+4,2].unpack("n").first
      peers.push Peer.new(ip, port, @hashed_info, @local_peer_id)
      index += 6
    end

    return peers
  end

end
