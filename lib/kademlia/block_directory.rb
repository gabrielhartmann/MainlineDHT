require_relative 'block_directory_errors'

class BlockDirectory
  attr_reader :pieces

  def initialize(metainfo, torrent_file_io)
    @metainfo = metainfo
    @torrent_file_io = torrent_file_io
    @pieces = initialize_pieces 
  end

  def refresh_pieces
    (0..@metainfo.info.pieces.length-1).each do |index|
      @pieces[index].complete = refresh_piece(index)
    end

    return @pieces
  end

  def refresh_piece(index)
    raise BlockDirectoryError, "Index of piece #{index} must be within range 0..#{@metainfo.info.pieces.length} inclusive." unless index >= 0 && index < @metainfo.info.pieces.length

    hash_from_metainfo = @metainfo.info.pieces[index]
    piece_from_file = @torrent_file_io.read(index, 0, @metainfo.info.piece_length) 
    hashed_piece = Digest::SHA1.digest(piece_from_file.block)
    return hashed_piece == hash_from_metainfo
  end

  def completed_pieces
    @pieces.select { |p| p.complete? }
  end

  def incomplete_pieces
    @pieces.select { |p| (!p.complete?) }
  end

  # Pieces which can be downloaded
  def available_pieces
    incomplete_pieces.select { |p| p.peers.length > 0 }
  end

  def unavailable_pieces
    incomplete_pieces.select { |p| p.peers.length == 0 }
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
    (0..@metainfo.info.pieces.length-2).each do |index|
      pieces << Piece.new(@metainfo.info.piece_length)
    end

    last_piece_length = @metainfo.info.length - (@metainfo.info.pieces.length - 1) * @metainfo.info.piece_length
    pieces << Piece.new(last_piece_length)

    return pieces
  end
end

class Piece
  attr_reader :length
  attr_reader :peers
  attr_reader :blocks
  attr_writer :complete

  def initialize(length, complete = false)
    @length = length
    @complete = complete
    @peers = Array.new
    @blocks = initialize_blocks
  end

  def complete?
    @complete
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
      blocks << Block.new(offset, block_length)
      offset += block_length
      length_left -= block_length
    end

    return blocks
  end
end

class Block
  attr_reader :length
  attr_reader :offset

  @@max_length = 2**14
  
  def initialize(offset, length)
    @offset = offset
    @length = length
  end

  def self.max_length
    @@max_length
  end
end
