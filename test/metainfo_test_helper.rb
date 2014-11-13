class Metainfo
  @@default_file = File.dirname(__FILE__) + '/tc08.mp3.torrent'
  @@default_metainfo = nil

  def self.default_file
    @@default_file
  end

  def self.default
    if (!@@default_metainfo)
      @@default_metainfo = Metainfo.new(@@default_file)
    end

    return @@default_metainfo
  end
end
