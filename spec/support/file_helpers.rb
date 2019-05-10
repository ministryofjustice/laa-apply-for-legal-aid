def ccms_data_from_file(filename)
  path = Rails.root.join 'spec/data/ccms', filename
  File.read path
end
