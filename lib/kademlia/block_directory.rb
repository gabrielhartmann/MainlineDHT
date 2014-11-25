require_relative 'block_directory_errors'

class BlockDirectory
  def initialize(metainfo, torrent_file_io)
    @metainfo = metainfo
    @torrent_file_io = torrent_file_io
    @last_piece_length = @metainfo.info.length - (@metainfo.info.pieces.length - 1) * @metainfo.info.piece_length
    @pieces = Array.new
  end

  def refresh_completed_pieces
    (0..@metainfo.info.pieces.length-1).each do |index|
      @pieces[index] = refresh_piece(index)
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
    # Get those pieces which are completed.  Since this is just an array of
    # bools at this point the select statement looks a little silly.  It's
    # yielding based on whether p is true
    @pieces.select { |p| p }
  end
end
