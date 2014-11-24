class Swarm
  attr_reader :metainfo

  def initialize(torrent_file)
    @metainfo = Metainfo.new(torrent_file)
  end

end
