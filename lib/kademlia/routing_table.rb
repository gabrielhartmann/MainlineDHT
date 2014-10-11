require_relative 'bucket'

class RoutingTable
  Default_Id_Space = 160

  attr_reader :id_space
  attr_reader :buckets

  def initialize (id_space = Default_Id_Space)
    @id_space = id_space
    @buckets = Array.new(1) {Bucket.new(id_space)}
  end

end
