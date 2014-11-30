require_relative 'metainfo'
require_relative 'torrent_file_io'
require_relative 'tracker'
require_relative 'block_directory'
require_relative 'swarm_errors'

class Swarm
  attr_reader :metainfo
  attr_reader :peers
  attr_reader :block_directory

  def initialize(torrent_file)
    @peer_id = (0...20).map { ('a'..'z').to_a[rand(26)] }.join
    @metainfo = Metainfo.new(torrent_file)
    @torrent_file_io = TorrentFileIO.new(@metainfo, torrent_file + ".part")
    @tracker = Tracker.new(@metainfo, @peer_id)
    @block_directory = BlockDirectory.new(@metainfo, @torrent_file_io)
    @peers = decode_peers(@tracker.peers)
  end

  def process_message(message, peer)
    case message
    when HaveMessage
      @block_directory.add_peer_to_piece(message.piece_index, peer)
    when BitfieldMessage
      bitfield = message.payload.unpack("B*").first

      (0..bitfield.length-1).each do |index|
	@block_directory.add_peer_to_piece(index, peer) if bitfield[index] == "1"
      end
    when PieceMessage
      @torrent_file_io.write(message)
      @block_directory.finish_block(message)
    else
      raise SwarmError, "Cannot process unsupported message: #{message.inspect}" 
    end
  end

  def interesting_peers
    int_peers = Array.new
    @block_directory.incomplete_pieces.each do |piece|
      piece.peers.each do |peer|
	int_peers << peer unless int_peers.include? peer
      end
    end

    return int_peers
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
