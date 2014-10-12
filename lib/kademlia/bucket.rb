require_relative 'bucket_errors'

class Bucket
  attr_reader :id_range
  attr_reader :nodes

  @@k_factor = 8

  def self.k_factor
    @@k_factor
  end

  def initialize(local_node, id_range)
    raise BucketTypeError "id_range must be a Range" unless id_range.class == Range
    
    @id_range = id_range
    @nodes = Array.new
    @local_node = local_node 
  end

  def split
    mid_point = (id_range.end / 2).to_i
    low_range = (id_range.begin..mid_point)
    high_range = (mid_point+1..id_range.end)

    low_bucket = Bucket.new(@local_node, low_range)
    high_bucket = Bucket.new(@local_node, high_range)

    return low_bucket, high_bucket
  end

  def add (node)
    validate_node(node)  
    @nodes << node 
  end

  def include_local_node?
    return id_range.include?(@local_node.peer_id)
  end

  private

  def validate_node (node)
    unless (@nodes.length < @@k_factor)
      raise BucketCapacityError, "k_factor is #{@@k_factor} with #{@nodes.length} nodes"
    end

    if (@nodes.include?(node))
	raise BucketDuplicateError, "node #{node} already exists in this bucket"
    end
  end
end
