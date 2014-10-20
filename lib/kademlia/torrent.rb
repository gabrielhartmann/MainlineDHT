require 'net/http'
require_relative 'announce_response'
require_relative 'id'
require_relative 'metainfo'
require_relative 'node'

class Torrent
  def initialize(torrent_file)
    @metainfo = Metainfo.new(torrent_file)
    @hashed_info = Digest::SHA1.digest(@metainfo.info.bencode)
    @url_info = CGI.escape(@hashed_info)
    @peer_id = peer_id = (0...20).map { ('a'..'z').to_a[rand(26)] }.join unless peer_id
    @port = 51413
    @uploaded = 0
    @downloaded = 0
    @left = @metainfo.info['length']
    @numwant = 50
    @compact = 1
    @support_crypto = 1
    @event = "started"
  end

  def announce_request 
    uri = URI(announce_url)
    response = Net::HTTP.get(uri)
    return AnnounceResponse.new(response)
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

end
