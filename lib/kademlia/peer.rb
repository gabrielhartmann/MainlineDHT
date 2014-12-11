require_relative 'peer_errors'
require_relative 'handshake_response'
require_relative 'messages'
require_relative 'peer_socket'
require_relative 'peer_respond_state_machine'
require_relative 'peer_send_state_machine'

class Peer
  attr_reader :logger
  attr_reader :id
  attr_reader :am_choking
  attr_reader :am_interested
  attr_reader :peer_choking
  attr_reader :peer_interested
  attr_reader :ip
  attr_reader :port
  attr_reader :hashed_info
  attr_reader :local_peer_id
  attr_reader :msg_proc_thread
  attr_reader :read_thread
  attr_reader :write_thread

  @@dht_bitmask = 0x0000000000000001
  @@request_sample_size = 1

  def initialize(logger, ip, port, hashed_info, local_peer_id, id = generate_id)
    raise InvalidPeerError, "The hashed info cannot be null" unless hashed_info
    @logger = logger
    @ip = ip
    @id = set_id(id)
    @port = port
    @hashed_info = hashed_info
    @local_peer_id = local_peer_id
    @socket = PeerSocket.open(self)
    @msg_recv_queue = Queue.new
    @msg_send_queue = Queue.new
  end

  def ==(another_peer)
    return @ip == another_peer.ip && @port == another_peer.port
  end

  def to_s
    "ip: #{@ip} port: #{@port} id: #{@id} hashed_info: #{@hashed_info} local_peer_id: #{@local_peer_id} handshake_response: #{@handshake_response}"
  end

  def address
    "#{@ip}:#{@port}"
  end

  def supports_dht?
    raise InvalidPeerError, "Cannot determine DHT support without a hand shake." unless @handshake_response
    (@handshake_response.reserved & @@dht_bitmask) != 0
  end

  def shake_hands
    # Only shake hands once
    return @handshake_response if @handshake_response != nil
    
    @handshake_response = @socket.shake_hands
    set_id(@handshake_response.peer_id)
    return @handshake_response
  end

  def read_next_message
    @socket.read
  end

  def write(message)
    @msg_send_queue.push(message)
    @logger.debug "#{address} Write queue size: #{@msg_send_queue.length}"
  end

  def join(swarm)
    @swarm = swarm
  end

  def connect
    raise InvalidPeerState, "Cannot connect a peer without a Swarm." unless @swarm
    shake_hands
    write(@swarm.block_directory.bitfield)
    @respond_machine = PeerRespondStateMachine.new(self)
    @send_machine = PeerSendStateMachine.new(self)
    start_msg_processing_thread
    start_read_thread
    start_write_thread
  end

  def disconnect
    stop_read_thread
    stop_msg_processing_thread
    stop_write_thread
    @msg_recv_queue = Queue.new
    @msg_send_queue = Queue.new
  end

  def process_read_msg(msg)
    case msg
    when HaveMessage, BitfieldMessage
      @swarm.process_message(msg, self)
      @respond_machine.eval_unchoke!
      @send_machine.recv_have!
    when UnchokeMessage
      @send_machine.recv_unchoke!
    when ChokeMessage
      @send_machine.recv_choke!
    when InterestedMessage
      @respond_machine.recv_interested!
    when NotInterestedMessage
      @respond_machine.recv_not_interested!
    when RequestMessage
      write(@swarm.process_msg(msg, self))
    when PieceMessage
      @swarm.process_message(msg, self)
      @send_machine.recv_piece!
    else
      @logger.debug "#{address} Read dropping #{msg.class}"
      return
    end

    @logger.debug "#{address} Read processed #{msg.class}"
  end

  def process_write_msg(msg)
    case msg
    when UnchokeMessage
      @respond_machine.send_unchoke!
    when InterestedMessage
      @send_machine.send_interested!
    when NotInterestedMessage
      @send_machine.send_not_interested!
    else
      @logger.debug "#{address} Write dropping #{msg.class}"
    end
  end

  def start_msg_processing_thread
    @logger.debug "#{address} Starting the message processing thread"

    @msg_proc_thread = Thread.new do
      loop do
	process_read_msg(@msg_recv_queue.pop)
      end
    end
  end

  def stop_msg_processing_thread
    @logger.debug "#{address} Stopping the message processing thread"
    Thread.kill(@msg_proc_thread)
  end

  def start_read_thread
    @logger.debug "#{address} Starting the read thread"

    @read_thread = Thread.new do
      loop do
	msg = read_next_message
	@logger.debug "#{address} Received #{msg.class}"
	@msg_recv_queue.push(msg)
      end
    end
  end

  def stop_read_thread
    @logger.debug "#{address} Stopping the read thread"
    Thread.kill(@read_thread)
  end

  def start_write_thread
    @logger.debug "#{address} Starting the write thread"

    @write_thread = Thread.new do
      loop do
	begin
	  msg = @msg_send_queue.pop
	  @logger.debug "#{address} Writing #{msg.class}"
	  @socket.write(msg)
	  process_write_msg(msg)
	rescue Exception => e
	  @logger.debug "#{address} Write thread caught exception #{e}"
	  raise
	end
      end
    end
  end

  def stop_write_thread
    @logger.debug "#{address} Stopping the write thread"
    Thread.kill(@write_thread)
  end

  def get_next_request(sample_size = @@request_sample_size)
    # Get a random piece from among a sample size of the pieces with the
    # fewest peers.  We don't want to hammer the peer with the rarest piece
    # necessarily.  So we choose a block from among a few of the least
    # available pieces.
    candidate_pieces = @swarm.block_directory.incomplete_pieces(self)
    return nil unless candidate_pieces.length > 0

    candidate_pieces.sort_by! { |p| p.peers.length }
    candidate_pieces = candidate_pieces.take(sample_size)
    piece = candidate_pieces.sample
    block = piece.incomplete_blocks.sample 
    @logger.debug "Next request block: #{block}"

    if (block)
      return block.to_wire
    else
      return nil
    end
  end

  def is_interesting?
    @swarm.interesting_peers.include?(self)
  end

  def should_unchoke?
    is_interesting?
  end

private

  def generate_id
    (0...20).map { ('a'..'z').to_a[rand(26)] }.join
  end

  def set_id(id)
    raise InvalidPeerError, "Peer ids must be 20 characters long." unless id.length == 20
    @id = id
  end

end
