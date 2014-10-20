require 'bencode'
require 'cgi'
require 'digest/sha1'

class Metainfo 
  attr_reader :announce
  attr_reader :announce_list
  attr_reader :comment
  attr_reader :creation_date
  attr_reader :info

  def initialize(torrent_file_name)
    metainfo = BEncode.load_file torrent_file_name
    @announce = metainfo['announce']
    @announce_list = metainfo['announce-list']
    @comment = metainfo['comment']
    @creation_date = metainfo['creation date']
    @info = metainfo['info']
  end

end
