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
    validate_range(id_range)
    
    @id_range = id_range
    @nodes = Array.new
    @local_node = local_node 
  end

  def split
    mid_point = id_range.begin + ((id_range.end - id_range.begin) / 2)

    low_range = (id_range.begin..mid_point)
    high_range = ((mid_point+1)..id_range.end)

    low_bucket = Bucket.new(@local_node, low_range)
    high_bucket = Bucket.new(@local_node, high_range)

    @nodes.each do |n|
      if (low_bucket.id_range.include?(n.id))
	low_bucket.add(n)
      elsif (high_bucket.id_range.include?(n.id))
	high_bucket.add(n)
      else
	raise BucketCorruptionError, "All nodes must fit into either the low or high bucket."
      end
    end

    return low_bucket, high_bucket
  end

  def add (node)
    raise BucketCapacityError, "Bucket is full" unless has_space? 
    validate_node(node)  
    @nodes << node 
  end

  def has_space?
    @nodes.length < Bucket.k_factor
  end

  def include_local_node?
    return id_range.include?(@local_node.id)
  end

  private

  def validate_node (node)
    local_bucket = include_local_node?
    if (@nodes.length == @@k_factor && local_bucket)
      raise BucketCapacityError, "k_factor is #{@@k_factor} with #{@nodes.length} nodes local_bucket #{local_bucket}"
    end

    if (@nodes.include?(node))
      raise BucketDuplicateError, "node #{node} already exists in this bucket"
    end

    if (!id_range.include?(node.id))
      raise BucketRangeError, "node ID #{node.id} is outside this bucket's range #{id_range}"
    end
  end

  def validate_range (range)
    raise BucketCorruptionError, "Bucket range must always be from low to high" if (range.begin > range.end)
  end
end
