require_relative 'metainfo'
require_relative 'torrent_file_io'
require_relative 'tracker'
require_relative 'block_directory'
require_relative 'swarm_errors'

class Swarm
  attr_reader :metainfo
  attr_reader :peers

  def initialize(torrent_file)
    @peer_id = (0...20).map { ('a'..'z').to_a[rand(26)] }.join
    @metainfo = Metainfo.new(torrent_file)
    @torrent_file_io = TorrentFileIO.new(@metainfo, @metainfo.info.name + ".part")
    @tracker = Tracker.new(@metainfo, @peer_id)
    @peers = decode_peers(@tracker.peers)
    @block_directory = BlockDirectory.new(@metainfo, @torrent_file_io)
  end

  def process_message(message, peer)
    case message
    when HaveMessage
      @block_directory.add_peer_to_piece(message.piece_index, peer)
    when BitfieldMessage
      bitfield = message.payload.unpack("B*").first

      (0..bitfield.length-1).each do |index|
	@block_directory.add_peer_to_piece(index, peer) if bitfield[0] == "1"
      end
    else
      raise SwarmError, "Cannot process unsupported message: #{message.inspect}" 
    end
  end

  private

  def decode_peers(encoded_peers)
    peers = Array.new
    index = 0
    while index + 6 <= encoded_peers.length
      ip = encoded_peers[index,4].unpack("CCCC").join('.')
      port = encoded_peers[index+4,2].unpack("n").first
      peers.push Peer.new(ip, port, @tracker.hashed_info, @peer_id)
      index += 6
    end

    return peers
  end
end
