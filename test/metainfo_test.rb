require 'bencode'
require 'cgi'
require_relative 'test_helper'
require_relative '../lib/kademlia/metainfo'

describe Metainfo do
  it "can encode the info section of a torrent file" do
    t = Metainfo.new(File.dirname(__FILE__) + '/ubuntu.torrent')
    CGI.escape(Digest::SHA1.digest(t.metainfo['info'].bencode)).must_equal t.hashed_info
  end
end
