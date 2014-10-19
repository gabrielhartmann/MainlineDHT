require 'bencode'
require 'cgi'
require 'digest/sha1'

class Metainfo 
  attr_reader :metainfo
  attr_reader :hashed_info

  def initialize(torrent_file_name)
    @metainfo = BEncode.load_file torrent_file_name

    # 1. Re-bencode the info section
    # 2. SHA1 hash the bencoded info section
    # 3. URL encode the SHA1 hash
    @hashed_info = CGI.escape(Digest::SHA1.digest(@metainfo['info'].bencode))
  end
end
