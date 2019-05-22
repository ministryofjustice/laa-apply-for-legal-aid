def ccms_data_file_path(filename)
  Rails.root.join 'spec/data/ccms', filename
end

def ccms_data_from_file(filename)
  File.read ccms_data_file_path(filename)
end
