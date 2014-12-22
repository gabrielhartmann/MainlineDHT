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
    @started_peers = Array.new
    @peer_semaphore = Mutex.new
  end

  def start(peers = @peers)
    @logger.info "Connecting to #{peers.length} peers"

    peer_threads = Array.new

    @peers.each do |peer|
      peer_threads << Thread.new do
	unless @started_peers.include? peer
	  begin
	    peer.join(self)
	    peer.connect
	    @peer_semaphore.synchronize do
	      @started_peers << peer
	    end
	  rescue
	    @logger.info "Failed to connect to #{peer}" 
	  end
	end
      end
    end

    peer_threads.each { |t| t.join }

    @logger.info "Connected to #{@started_peers.length} peers"
  end

  def stop
    @logger.info "Disconnecting from #{@started_peers.length} peers"

    peer_threads = Array.new
    @started_peers.each do |peer|
      @logger.info "Disconnecting from #{peer}"
      peer.disconnect
    end

    @logger.info "Disconnected from #{@started_peers.length} peers"
    @started_peers = Array.new
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

  def downloaded
    downloaded = 0
    @block_directory.completed_blocks.each { |block| downloaded += block.length }
    return downloaded
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
