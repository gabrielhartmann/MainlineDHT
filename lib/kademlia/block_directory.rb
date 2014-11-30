require_relative 'block_directory_errors'

class BlockDirectory
  attr_reader :pieces
  attr_reader :blocks
  attr_reader :bitfield

  @@block_directory_bitfield_suffix = ".bitfield"

  def initialize(metainfo, torrent_file_io, auto_refresh = true)
    @metainfo = metainfo
    @torrent_file_io = torrent_file_io
    @pieces = initialize_pieces 
    @blocks = all_blocks
    @bitfield_file_name = @torrent_file_io.file_name + @@block_directory_bitfield_suffix 

    # This creates an @bitfield member which is a BitfieldMessage
    # It is updated when Pieces are completed
    refresh_pieces if auto_refresh
  end

  def to_s
    s = "\n"
    s << "bitfield: #{@bitfield}\n"
    s << "completed pieces: #{completed_pieces_percentage.round(2)}%\n"
    s << "completed pieces count: #{completed_pieces.length}\n"
    s << "completed blocks: #{completed_blocks_percentage.round(2)}%\n"
    s << "completed blocks count: #{completed_blocks.length}\n"
    s << "unavailable pieces: #{unavailable_pieces.length}\n"
  end

  def completed_pieces_percentage
    completed_pieces.length.to_f / @pieces.length * 100.0
  end

  def completed_blocks_percentage
    completed_blocks.length.to_f / @blocks.length * 100.0
  end

  def refresh_pieces
    if (File.exists?(@bitfield_file_name))
      read_bitfield
    else
      puts "#{@bitfield_file_name} doesn't exist."
      piece_array_length = @metainfo.info.pieces.length
      threads = Array.new

      @pieces.each do |piece|
	print "#{piece.index.to_f/pieces.length * 100.0} "
	piece.finish if piece_finished?(piece.index)
      end

      write_bitfield
    end

    return @pieces
  end

  def read_bitfield
    @bitfield = Marshal.load(File.read(@bitfield_file_name)) 
    decoded_bitfield = @bitfield.payload.unpack("B*").first

    @pieces.each do |piece|
      piece.finish if decoded_bitfield[piece.index] == "1"
    end
  end

  def write_bitfield
    bitfield_string = String.new

    @pieces.each do |piece|
      if (piece.complete?)
	bitfield_string << "1"
      else
	bitfield_string << "0"
      end
    end

    File.delete(@bitfield_file_name) if File.exists(@bitfield_file_name)
    @bitfield = BitfieldMessage.Create(bitfield_string)
    File.open(@bitfield_file_name, 'w') { |f| f.write(Marshal.dump(@bitfield)); f.close }
  end

  def piece_finished?(index)
    raise BlockDirectoryError, "Index of piece #{index} must be within range 0..#{@metainfo.info.pieces.length} inclusive." unless index >= 0 && index < @metainfo.info.pieces.length

    hash_from_metainfo = @metainfo.info.pieces[index]
    piece_from_file = @torrent_file_io.read(index, 0, @metainfo.info.piece_length) 
    block = piece_from_file.block
    hashed_piece = Digest::SHA1.digest(block)
    return hashed_piece == hash_from_metainfo
  end

  def all_pieces(peer = nil)
    pieces = @pieces

    if (peer)
      pieces = pieces.select { |p| p.peers.include? peer }
    end

    return pieces
  end

  def completed_pieces(peer = nil)
    all_pieces(peer).select { |p| p.complete? }
  end

  def incomplete_pieces(peer = nil)
    pieces = all_pieces(peer).select { |p| !p.complete? }
    return pieces.sort_by! { |p| p.peers.length }
  end

  def all_blocks(peer = nil)
    pieces = all_pieces(peer)
    blocks = Array.new

    pieces.each do |p|
      blocks.concat(p.blocks)
    end

    return blocks
  end

  def incomplete_blocks(peer = nil)
    blocks = all_blocks(peer).select { |b| !b.complete? }
  end
  
  def completed_blocks(peer = nil)
    blocks = all_blocks(peer).select { |b| b.complete? }
  end

  # Pieces which can be downloaded
  def available_pieces
    all_pieces.select { |p| p.peers.length > 0 }
  end

  def unavailable_pieces
    incomplete_pieces.select { |p| p.peers.length == 0 }
  end

  def finish_block(piece_message)
    piece_index = piece_message.index

    @pieces[piece_index].finish_block(piece_message.begin)

    # All blocks in the piece are marked completed
    if (@pieces[piece_index].complete?)
      # Block hashes properly
      if (piece_finished?(piece_index))
	write_bitfield
      else
	puts "Error: Piece was supposed to be complete, but did not hash correctly."
	@pieces[piece_index].clear
      end
    end
  end

  def add_peer_to_piece(index, peer)
    @pieces[index].add_peer(peer)
  end

  def remove_peer(peer)
    @pieces.each do |piece|
      piece.peers.delete(peer)
    end
  end

  private

  def initialize_pieces
    pieces = Array.new
    piece_count = @metainfo.info.pieces.length
    (0..piece_count-2).each do |index|
      pieces << Piece.new(index, @metainfo.info.piece_length)
    end

    last_piece_length = @metainfo.info.length - (@metainfo.info.pieces.length - 1) * @metainfo.info.piece_length
    pieces << Piece.new(piece_count-1, last_piece_length)

    return pieces
  end
end

class Piece
  attr_reader :index
  attr_reader :length
  attr_reader :peers
  attr_reader :blocks

  def initialize(index, length)
    @index = index
    @length = length
    @peers = Array.new
    @blocks = initialize_blocks
  end

  def finish 
    @blocks.each do |block|
      block.complete = true
    end
  end

  def clear
    @blocks.each do |block|
      block.complete = false
    end
  end

  def finish_block(offset)
    @blocks.each do |b|
      if (b.offset == offset)
	b.complete = true 
	return
      end
    end
  end

  def incomplete_blocks
    @blocks.select { |b| !b.complete? }
  end

  def complete_blocks
    @blocks.select { |b| b.complete? }
  end

  def complete?
    incomplete_blocks.length == 0
  end

  def add_peer(peer)
    unless (@peers.include? peer)
      @peers << peer
    end
  end

  private

  def initialize_blocks
    length_left = @length
    offset = 0
    blocks = Array.new

    while (length_left > 0)
      block_length = [Block.max_length, length_left].min
      blocks << Block.new(@index, offset, block_length)
      offset += block_length
      length_left -= block_length
    end

    return blocks
  end
end

class Block
  attr_reader :index
  attr_reader :offset
  attr_reader :length
  attr_writer :complete

  @@max_length = 2**14
  
  def initialize(index, offset, length, complete = false)
    @index = index
    @offset = offset
    @length = length
    @complete = complete
  end

  def ==(another_block)
    return @index == another_block.index && @offset == another_block.offset && @length == another_block.length
  end

  def self.max_length
    @@max_length
  end

  def complete?
    @complete
  end

  def to_wire
    RequestMessage.create(@index, @offset, @length)
  end
end
