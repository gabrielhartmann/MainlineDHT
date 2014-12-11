require 'logger'
require_relative 'metainfo'
require_relative 'torrent_file_io'
require_relative 'tracker'
require_relative 'block_directory'
require_relative 'swarm_errors'

class Swarm
  attr_reader :metainfo
  attr_reader :peers
  attr_reader :block_directory

  def initialize(torrent_file, log_level = Logger::DEBUG)
    @logger = Logger.new('swarm.log', 10, 1024000)
    @logger.level = log_level
    @peer_id = (0...20).map { ('a'..'z').to_a[rand(26)] }.join
    @metainfo = Metainfo.new(torrent_file)
    @torrent_file_io = TorrentFileIO.new(@logger, @metainfo, torrent_file + ".part")
    @tracker = Tracker.new(@logger, @metainfo, @peer_id)
    @block_directory = BlockDirectory.new(@logger, @metainfo, @torrent_file_io)
    @peers = decode_peers(@tracker.peers)
  end

  def start(peer_count = @peers.length)
    @logger.info "Connecting to #{peer_count} peers"
    @started_peers = Array.new
    @peers.first(peer_count).each do |peer|
      begin
	peer.join(self)
	peer.connect
	@started_peers << peer
      rescue
	@logger.info "Failed to connect to #{peer}" 
      end
    end
  end

  def stop
    @started_peers.each do |peer|
      peer.disconnect
    end
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
    when RequestMessage
      return @torrent_file_io.read(message)
    when PieceMessage
      @torrent_file_io.write(message)
      @block_directory.finish_block(message)
    else
      raise SwarmError, "Cannot process unsupported message: #{message.inspect}" 
    end
  end

  def broadcast(message)
    @peers.each do |peer|
      peer.write(message)
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
      peers.push Peer.new(@logger, ip, port, @tracker.hashed_info, @peer_id)
      index += 6
    end

    @logger.info "#{peers.length} peers decoded"
    return peers
  end
end
