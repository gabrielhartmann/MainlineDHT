require 'bencode'
require 'cgi'
require 'digest/sha1'

class Metainfo 
  attr_reader :announce
  attr_reader :announce_list
  attr_reader :comment
  attr_reader :creation_date
  attr_reader :info
  attr_reader :info_raw

  def initialize(torrent_file_name)
    metainfo = BEncode.load_file torrent_file_name
    @announce = metainfo['announce']
    @announce_list = metainfo['announce-list']
    @comment = metainfo['comment']
    @creation_date = metainfo['creation date']
    @info_raw = metainfo['info']
    @info = Info.new(metainfo['info'])
  end
end

class Info
  attr_reader :piece_length
  attr_reader :pieces
  attr_reader :info_raw
  attr_reader :length
  attr_reader :name

  @@hash_length = 20

  def initialize(info)
    @info_raw = info
    @piece_length = info['piece length']
    @pieces = read_pieces
    @length = info['length']
    @name = info['name']
  end

  def read_pieces
    pieces_raw = @info_raw['pieces']
    piece_count = pieces_raw.length / @@hash_length

    # Calculate indices 0, 20, 40, 60
    piece_indices = (0..piece_count-1).to_a.map { |x| x * @@hash_length }

    # Generate unpack strings @0a20, @20a20, @40a20.  @x indicates offset x.
    # a20 indicates an arbitrary binary string of 20 bytes
    unpack_strings = piece_indices.map { |index| "@#{index}a#{@@hash_length}" }

    # Get the 20 byte arbitrary strings at the offsets indicated by the unpack_strings
    # Each of these unpack requests generates a single member array, hence the need
    # for a call to first
    unpack_strings.map { |unpack_string| pieces_raw.unpack(unpack_string).first }
  end

end
