require 'net/http'
require 'socket'
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

  def shake_hands
    response = announce_request
    peer = response.peers.first
    s = TCPSocket.open(peer.ip, peer.port)
    s.send("\023BitTorrent protocol\0\0\0\0\0\0\0\0", 0);
    s.send("#{@hashed_info}#{@peer_id}", 0)

    len = s.recv(1)[0]
    puts "length: #{len.inspect}"

    protocol = s.recv(19)
    puts "protocol: #{protocol.inspect}"

    reserved = s.recv(8)
    puts "reserved: #{reserved.inspect}" 

    their_hash = s.recv(20)
    puts "their info hash: #{their_hash.inspect}"
    
    peerid = s.recv(20)
    puts "their peer_id: #{peerid}"

    # s.print()

    s.close
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
