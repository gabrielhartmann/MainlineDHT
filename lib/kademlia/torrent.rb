require 'net/http'
require 'socket'
require_relative 'announce_response'
require_relative 'id'
require_relative 'metainfo'
require_relative 'node'

class Torrent
  attr_reader :hashed_info
  attr_reader :peers

  def initialize(torrent_file)
    @metainfo = Metainfo.new(torrent_file)
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

    @peers = announce_request.peers
    if (File.exists?(@metainfo.info.name))
      @file = File.new(@metainfo.info.name, "r+")
    else
      @file = File.new(@metainfo.info.name, "w")
    end
  end

  def write(piece)
    piece_offset = piece.index * @metainfo.info.piece_length
    file_offset = piece_offset + piece.begin
    @file.seek(file_offset)
    @file.write(piece.block)
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

end
