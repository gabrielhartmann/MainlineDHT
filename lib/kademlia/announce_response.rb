require 'bencode'
require_relative 'peer'

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
    @peers = decoded_response['peers']
  end
end
