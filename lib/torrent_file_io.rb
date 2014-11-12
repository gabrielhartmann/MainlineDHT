require_relative 'torrent_writer'
require_relative 'torrent_reader'

class TorrentFileIO
  def initialize(metainfo, file_name = nil)
    @metainfo = metainfo
    file_name = metainfo.info.name unless file_name

    @writer = TorrentWriter.new(metainfo, file_name)
    @reader = TorrentReader.new(metainof, file_name)
  end

  def write(piece)
    @writer.write(piece)
  end

  def read(idx, bgn, length)
  end
end
