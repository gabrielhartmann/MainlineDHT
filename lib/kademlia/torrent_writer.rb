require_relative 'torrent_io_utils'

class TorrentWriter
  attr_reader :file
  attr_reader :metainfo
  
  def initialize(metainfo, file_name)
    @metainfo = metainfo
    @file_name = file_name
  end

  def write(piece)
    file_offset = get_file_offset(@metainfo, piece.index, piece.begin)
    IO.write(@file_name, piece.block, file_offset);
  end
end
