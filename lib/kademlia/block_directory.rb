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

  def add_peer_to_piece(index, peer)
      @pieces[index].add_peer(peer)
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
  attr_writer :complete

  def initialize(length, complete = false)
    @length = length
    @complete = complete
    @peers = Array.new
  end

  def complete?
    @complete
  end

  def add_peer(peer)
    unless (@peers.include? peer)
      @peers << peer
    end
  end
end
