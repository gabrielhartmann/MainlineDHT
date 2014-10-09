require 'bucket'

class RoutingTable
  Default_Id_Space = 160

  attr_reader :id_space

  def initialize (id_space = Default_Id_Space)
    @id_space = id_space
    @bucket_list = Array.new(1) {Bucket.new(id_space)}
  end

  def bucket_count
    @bucket_list.length
  end
end
