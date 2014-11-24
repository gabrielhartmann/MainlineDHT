require_relative 'metainfo'
require_relative 'torrent_file_io'
require_relative 'tracker'

class Swarm
  attr_reader :metainfo
  attr_reader :peers

  def initialize(torrent_file)
    @peer_id = (0...20).map { ('a'..'z').to_a[rand(26)] }.join
    @metainfo = Metainfo.new(torrent_file)
    @torrent_file_io = TorrentFileIO.new(@metainfo)
    @tracker = Tracker.new(@metainfo)
    @peers = decode_peers(@tracker.peers)
  end

  private

  def decode_peers(encoded_peers)
    peers = Array.new
    index = 0
    while index + 6 <= encoded_peers.length
      ip = encoded_peers[index,4].unpack("CCCC").join('.')
      port = encoded_peers[index+4,2].unpack("n").first
      peers.push Peer.new(ip, port, @tracker.hashed_info, @peer_id)
      index += 6
    end

    return peers
  end
end
