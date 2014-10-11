require_relative 'bucket'

class RoutingTable
  attr_reader :id_space
  attr_reader :buckets

  @@Default_Id_Space = 160

  def initialize (id_space = @@Default_Id_Space)
    @id_space = id_space
    @buckets = Array.new(1) {Bucket.new(id_space)}
  end

  def self.default_id_space
    @@Default_Id_Space
  end

end
