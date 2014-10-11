module Id

  @@default_range = (0..2**160)

  def self.generate (range = @@default_range)
    rand(range)
  end

  def self.default_range
    @@default_range
  end
end
