def ccms_data_from_file(filename)
  path = Rails.root.join 'spec/data/ccms', filename
  File.read path
end

def squish_xml(xml)
  xml.gsub(/\n\s+/, "\n ")
end

def remove_xml_header(xml)
  xml.gsub("<?xml version='1.0' encoding='UTF-8'?>\n", '')
end
