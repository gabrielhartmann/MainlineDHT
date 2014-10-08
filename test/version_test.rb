require_relative 'test_helper'
require_relative '../lib/kademlia/version'

describe Kademlia do

  it "version must be defined" do
    Kademlia::VERSION.wont_be_nil
  end

end
