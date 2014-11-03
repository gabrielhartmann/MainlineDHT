require_relative 'test_helper'
require_relative 'metainfo_test_helper'
require_relative '../lib/kademlia/metainfo'

describe Metainfo do

  it "can read a .torrent file" do
    Metainfo.default
  end

  it "must have hashes of length 20 for all pieces" do
    Metainfo.default.info.pieces.each { |piece| piece.length.must_equal 20 }
  end
end
