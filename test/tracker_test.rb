require 'bencode'
require 'cgi'
require_relative 'test_helper'
require_relative '../lib/kademlia/tracker'

describe Tracker do
  it "can process a torrent file" do
    t = Tracker.new('ubuntu.torrent')
    CGI.escape(Digest::SHA1.digest(t.metainfo['info'].bencode)).must_equal t.hashed_info
  end
end
