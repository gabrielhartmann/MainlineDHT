require_relative 'torrent_io_utils'
require_relative 'messages'

class TorrentReader
  attr_reader :file
  attr_reader :metainfo
  
  def initialize(metainfo, file_name)
    @metainfo = metainfo
    @file_name = file_name
  end

  def read(idx, bgn, length)
    file_offset = get_file_offset(@metainfo, idx, bgn)
    block = IO.read(@file_name, length, file_offset)
    PieceMessage.Create(idx, bgn, block)
  end
end
