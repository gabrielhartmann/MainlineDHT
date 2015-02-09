require 'socket'
require_relative 'handshake_response'
require_relative 'peer_protocol_errors'
require_relative 'async_processor'

class PeerSocket
  attr_reader :msg_proc_thread
  attr_reader :read_thread
  attr_reader :write_thread

  def initialize(logger, peer)
    @logger = logger
    @peer = peer 
    @msg_send_queue = Queue.new
  end

  def address
    "#{@peer.ip}:#{@peer.port}"
  end

  def self.open(logger, peer)
    PeerSocket.new(logger, peer)
  end

  def close
    stop_read_thread
    stop_msg_processing_thread
    stop_write_thread

    @socket.close if @socket && !@socket.closed?
  end

  def shake_hands
    begin
      @socket = TCPSocket.open(@peer.ip, @peer.port)
      @socket.send("\023BitTorrent protocol\0\0\0\0\0\0\0\0", 0);
      @socket.send("#{@peer.hashed_info}#{@peer.local_peer_id}", 0)

      length = @socket.read(1)[0]
      protocol = @socket.read(19)
      reserved = @socket.read(8)
      info_hash = @socket.read(20)
      peer_id = @socket.read(20)

      start_msg_processing_thread
      start_read_thread
      start_write_thread

      return HandShakeResponse.new(length, protocol, reserved, info_hash, peer_id)

    rescue Exception => e
      close
      raise PeerProtocolError, "Failed to shake hands with exception: #{e}"
    end
  end

  def read
    length = @socket.read(4).unpack("L>").first
    raise PeerProtocolError, "Invalid message length." unless length >= 0

    if (length > 0)
      payload = @socket.read(length)
    end

    return PeerMessage.Create(length, payload)
  end

  def write(message)
    @socket.write(message.to_wire)
  end

  def write_async(message)
    @msg_send_queue.push(message)
    @logger.debug "#{address} Write queue size: #{@msg_send_queue.length}"
  end

  def start_msg_processing_thread
    @logger.debug "#{address} Starting the message processing thread"
    @msg_processor = AsyncProcessor.new(Proc.new {|msg| @peer.process_read_msg(msg)})
  end

  def stop_msg_processing_thread
    @msg_processor = nil
  end

  def start_read_thread
    @logger.debug "#{address} Starting the read thread"

    @read_thread = Thread.new do
      loop do
	msg = read
	@logger.debug "#{address} Received #{msg.class}"
	@msg_processor.enqueue(msg)
      end
    end
  end

  def stop_read_thread
    if (@read_thread)
      @logger.debug "#{address} Stopping the read thread"
      Thread.kill(@read_thread)
    else
      @logger.debug "#{address} No read thread to stop"
    end
  end

  def start_write_thread
    @logger.debug "#{address} Starting the write thread"

    @write_thread = Thread.new do
      loop do
	begin
	  msg = @msg_send_queue.pop
	  @logger.debug "#{address} Writing #{msg.class}"
	  write(msg)
	  @peer.process_write_msg(msg)
	rescue Exception => e
	  @logger.debug "#{address} Write thread caught exception #{e}"
	  raise
	end
      end
    end
  end

  def stop_write_thread
    if (@write_thread)
      @logger.debug "#{address} Stopping the write thread"
      Thread.kill(@write_thread)
    else
      @logger.debug "#{address} No write thread to stop"
    end
  end
end
