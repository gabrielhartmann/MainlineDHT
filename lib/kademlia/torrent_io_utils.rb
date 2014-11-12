require_relative 'metainfo'

def get_file_offset(metainfo, idx, bgn)
  piece_offset = idx * metainfo.info.piece_length
  file_offset = piece_offset + bgn
end
