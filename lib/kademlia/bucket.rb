class Bucket
  attr_reader :id_range

  def initialize(id_range)
    @id_range = id_range
  end

  def split
    mid_point = (id_range.end / 2).to_i
    low_range = (id_range.begin..mid_point)
    high_range = (mid_point+1..id_range.end)

    low_bucket = Bucket.new(low_range)
    high_bucket = Bucket.new(high_range)

    return low_bucket, high_bucket
  end
end
