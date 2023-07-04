def load_ccms_attribute_array(path)
  CSV.readlines(Rails.root.join("spec/fixtures/files/ccms_attributes", path)).each_with_object([]) do |line, output|
    key = line[0].parameterize.to_sym
    output << if line[1].nil?
                [key]
              else
                [key, line[1]]
              end
  end
end
