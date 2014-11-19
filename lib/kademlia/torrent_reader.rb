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
    puts @file_name
    raw_read = IO.read(@file_name, length, file_offset)
    raw_message = [7, idx, bgn, raw_read.bytes].flatten.pack("CL>L>C*")
    PeerMessage.Create(raw_message.length, raw_message)
  end
end
