require 'net/http'
require 'socket'
require_relative 'announce_response'
require_relative 'id'
require_relative 'metainfo'
require_relative 'node'
require_relative 'torrent_file_io'

class Torrent
  attr_reader :hashed_info
  attr_reader :peers

  def initialize(torrent_file)
    @metainfo = Metainfo.new(torrent_file)
    @torrent_file_io = TorrentFileIO.new(@metainfo)

    @hashed_info = Digest::SHA1.digest(@metainfo.info_raw.bencode)
    @url_info = CGI.escape(@hashed_info)
    @peer_id = peer_id = (0...20).map { ('a'..'z').to_a[rand(26)] }.join unless peer_id
    @port = 51413
    @uploaded = 0
    @downloaded = 0
    @left = @metainfo.info.length
    @numwant = 50
    @compact = 1
    @support_crypto = 1
    @event = "started"
    @peers = decode_peers(announce_request.peers)
  end

  def write(piece)
    @torrent_file_io.write(piece)
  end

private
  def announce_url
    "#{@metainfo.announce}"\
    "?info_hash=#{@url_info}"\
    "&peer_id=#{@peer_id}"\
    "&port=#{@port}"\
    "&uploaded=#{@uploaded}"\
    "&downloaded=#{@downloaded}"\
    "&left=#{@left}"\
    "&numwant=#{@numwant}"\
    "&compact=#{@compact}"\
    "&supportcrypt=#{@support_crypt}"\
    "&event=#{@event}"
  end

  def announce_request 
    uri = URI(announce_url)
    response = Net::HTTP.get(uri)
    return AnnounceResponse.new(response, @hashed_info, @peer_id)
  end

  def decode_peers(encoded_peers)
    peers = Array.new
    index = 0
    while index + 6 <= encoded_peers.length
      ip = encoded_peers[index,4].unpack("CCCC").join('.')
      port = encoded_peers[index+4,2].unpack("n").first
      peers.push Peer.new(ip, port, @hashed_info, @local_peer_id)
      index += 6
    end

    return peers
  end
end
