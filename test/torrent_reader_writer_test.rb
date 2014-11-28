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

  it "can determine whether pieces are complete" do
    metainfo = Metainfo.new(File.dirname(__FILE__) + '/tc08.mp3.torrent')
    torrent_file_io = TorrentFileIO.new(metainfo, File.dirname(__FILE__) + "/tc08.mp3")

    i = 0
    metainfo.info.pieces.each do |piece_from_metainfo|
      piece_from_file = torrent_file_io.read(i, 0, metainfo.info.piece_length) 
      hashed_piece = Digest::SHA1.digest(piece_from_file.block)

      hashed_piece.must_equal piece_from_metainfo
      i += 1
    end
  end

  it "can determine whether pieces are complete" do
    metainfo = Metainfo.new(File.dirname(__FILE__) + '/tc08.mp3.torrent')
    torrent_file_io = TorrentFileIO.new(metainfo, File.dirname(__FILE__) + "/tc08.mp3.part")

    i = 0
    failed_matches = 0
    metainfo.info.pieces.each do |piece_from_metainfo|
      piece_from_file = torrent_file_io.read(i, 0, metainfo.info.piece_length) 
      hashed_piece = Digest::SHA1.digest(piece_from_file.block)

      if (hashed_piece != piece_from_metainfo)
	failed_matches += 1
      end
      i += 1
    end

    failed_matches.must_equal 7
    (metainfo.info.pieces.length > failed_matches).must_equal true
  end

  it "creates the file if it doesn't exist upon creation" do
    file_name = "file_does_not_exist"
    File.exists?(file_name).must_equal false

    begin
      metainfo = Metainfo.default
      torrent_file_io = TorrentFileIO.new(metainfo, file_name)

      File.exists?(file_name).must_equal true
      File.size?(file_name).must_equal metainfo.info.length

      File.delete(file_name)
      File.exists?(file_name).must_equal false
    rescue
      File.delete(file_name)
      raise
    end
  end
end
