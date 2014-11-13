require_relative 'test_helper'
require_relative 'metainfo_test_helper'
require_relative '../lib/kademlia/torrent_file_io'
require_relative '../lib/kademlia/messages'

describe TorrentFileIO do
  it "can write to a file and read back what it wrote" do
    payload = PieceMessage.get_payload(0, 0, "HelloWorld")
    piece_msg_in = PieceMessage.new(payload)

    metainfo = Metainfo.default
    file_name = "test_file_read_write"
    torrent_file_io = TorrentFileIO.new(metainfo, file_name)

    length = torrent_file_io.write(piece_msg_in)
    piece_msg_out = torrent_file_io.read(piece_msg_in.index, piece_msg_in.begin, length)
    
    piece_msg_out.index.must_equal piece_msg_in.index
    piece_msg_out.begin.must_equal piece_msg_in.begin
    piece_msg_out.block.must_equal piece_msg_in.block
    piece_msg_out.length.must_equal piece_msg_in.length
    piece_msg_out.id.must_equal piece_msg_in.id
    piece_msg_out.payload.must_equal piece_msg_in.payload

    File.delete(file_name)
  end
end
