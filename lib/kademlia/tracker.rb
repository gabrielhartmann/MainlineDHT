require 'net/http'
require 'socket'
require_relative 'announce_response'
require_relative 'id'
require_relative 'metainfo'
require_relative 'node'
require_relative 'peer_errors'

class Tracker 
  attr_reader :hashed_info
  attr_reader :peers
  attr_reader :peer_id

  def initialize(metainfo, peer_id = nil)
    peer_id = (0...20).map { ('a'..'z').to_a[rand(26)] }.join unless peer_id
    @peer_id = peer_id
    raise InvalidPeerError, "Peer ids must have a length of 20 not #{@peer_id.length}" unless @peer_id.length == 20

    @metainfo = metainfo
    @hashed_info = Digest::SHA1.digest(@metainfo.info_raw.bencode)
    @url_info = CGI.escape(@hashed_info)
    @port = 51413
    @uploaded = 0
    @downloaded = 0
    @left = @metainfo.info.length
    @numwant = 50
    @compact = 1
    @support_crypto = 1
    @event = "started"
    @peers = announce_request.peers
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
