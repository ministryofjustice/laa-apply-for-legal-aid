module XMLEntitykMatchers
  RSpec::Matchers.define :have_means_entity do |expected|
    match do |actual_xml|
      doc = Nokogiri::XML(actual_xml).remove_namespaces!
      entity_block = doc.xpath %(//MeansAssesments//AssesmentDetails//Entity[EntityName = "#{expected}"])
      expect(entity_block).not_to be_empty
    end

    failure_message do
      "Unable to find entity block #{expected}"
    end
  end
end
