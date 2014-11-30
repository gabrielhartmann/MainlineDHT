require_relative 'block_directory_errors'

class BlockDirectory
  attr_reader :pieces

  @@block_directory_bitfield_suffix = ".bitfield"

  def initialize(metainfo, torrent_file_io, auto_refresh = true)
    @metainfo = metainfo
    @torrent_file_io = torrent_file_io
    @pieces = initialize_pieces 
    @bitfield_file_name = @torrent_file_io.file_name + @@block_directory_bitfield_suffix 
    refresh_pieces if auto_refresh
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

  def completed_pieces(peer = nil)
    pieces = @pieces.select { |p| p.complete? }

    if (peer)
      pieces = pieces.select { |p| p.peers.include? peer }
    end

    return pieces
  end

  def incomplete_pieces(peer = nil)
    pieces = @pieces.select { |p| !p.complete? }

    if (peer)
      pieces = pieces.select { |p| p.peers.include? peer }
    end

    return pieces.sort_by! { |p| p.peers.length }
  end

  def incomplete_blocks(peer = nil)
    pieces = incomplete_pieces(peer)
    blocks = Array.new

    pieces.each do |p|
      blocks.concat(p.incomplete_blocks)
    end

    return blocks
  end

  # Pieces which can be downloaded
  def available_pieces
    incomplete_pieces.select { |p| p.peers.length > 0 }
  end

  def unavailable_pieces
    incomplete_pieces.select { |p| p.peers.length == 0 }
  end

  def finish_block(piece_index, block_index)
    @pieces[piece_index].finish_block(block_index)

    # All blocks marked completed
    if (@pieces[piece_index].complete?)
      # Block hashes properly
      if (piece_finished?(piece_index))
	write_bitfield
      else
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

  def finish_block(index)
    @blocks[index].complete = true
  end

  def incomplete_blocks
    @blocks.select { |b| !b.complete? }
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
