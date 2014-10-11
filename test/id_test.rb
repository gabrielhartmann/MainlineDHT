require_relative 'test_helper'
require_relative '../lib/kademlia/id'

describe Id do
  it "can create IDs from a default id range" do 
    id = Id.generate
    Id.default_range.include?(id).must_equal true
  end

  it "can create Ids from a custom id range" do
    custom_range = (-10..-1)
    id = Id.generate(custom_range)
    custom_range.include?(id).must_equal true
  end
end
