require_relative 'bucket'
require_relative 'routing_table_errors'

class RoutingTable
  attr_reader :id_space
  attr_reader :buckets

  @@Default_Id_Space = (0..2**160) 

  def self.default_id_space
    @@Default_Id_Space
  end

  def initialize (local_node, id_space = @@Default_Id_Space)
    raise RoutingTableTypeError, "id_space must be a Range" unless id_space.is_a?(Range)
    @id_space = id_space
    @buckets = Array.new(1) {Bucket.new(local_node, id_space)}
  end
  
  def add (node)
    raise RoutingTableTypeError, "node must be a Node" unless node.is_a?(Node)

    bucket = nil
    @buckets.each { |b| bucket = b if b.id_range.include?(node.peer_id) }

    if (bucket)
      if (bucket.has_space?)
	bucket.add(node)
      end
    else
      raise RoutingTableCorruptionError, "No bucket found for a node"
    end

    normalize
  end

  def normalize
    bucket_to_be_split = get_splittable_bucket
    return if !bucket_to_be_split

    # It's possible that we split a bucket which is at capacity
    # but all the nodes happen to be on one side of the split
    # so we've not eased the capacity problem in that bucket.
    # Therefore, below we loop and continuously split buckets
    # until we cannot find a splittable bucket
    while (bucket_to_be_split)
      del_bucket(bucket_to_be_split)
      bucket_to_be_split.split.each { |b| add_bucket(b) }
      bucket_to_be_split = get_splittable_bucket
    end
  end

  def nodes
    nodes = Array.new
    @buckets.each { |b| nodes.push(*b.nodes) }
    return nodes
  end

  private

  def add_bucket(b)
    raise RoutingTableCorruptionError, "Must add a bucket" unless b.is_a?(Bucket)
    @buckets << b
  end

  def del_bucket(b)
    raise RoutingTableCorruptionError, "Must delete a bucket" unless b.is_a?(Bucket)
    length_before = @buckets.length
    @buckets.delete(b)
    length_after = @buckets.length

    raise RoutingTableCorruptionError, "Bucket must be deleted" if length_after >= length_before
  end

  def get_splittable_bucket
    local_bucket = get_local_bucket
    local_bucket_occupation = local_bucket.nodes.length
    
    if (local_bucket_occupation == Bucket.k_factor)
      return local_bucket
    elsif (local_bucket_occupation > Bucket.k_factor)
      raise RoutingTableCorruptionError, "The local bucket should never exceed the k factor"
    else
      return nil
    end
  end

  def get_local_bucket
    local_bucket = nil
    local_bucket_count = 0

    @buckets.each do |b|
      if (b.include_local_node?)
	local_bucket = b
	local_bucket_count += 1
      end
    end
     
    raise RoutingTableCorruptionError, "There should only be one bucket for the local node." if local_bucket_count > 1
    raise RoutingTableCorruptionError, "There should always be a bucket for the local node." if !local_bucket

    return local_bucket
  end
end
