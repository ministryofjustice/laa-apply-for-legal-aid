require 'nokogiri'
require 'csv'

#
# This class is useful for printing out all the attributes in the merits and means sections of a ccms payload file
#
#
class CCMSPayloadAnalyser
  def initialize
    @doc = File.open(Rails.root.join('ccms_integration/example_payloads/NonPassportedFullMonty.xml')) { |f| Nokogiri::XML(f).remove_namespaces! }
    # NOTE: Assessments is mispelt Assesment in XML file!
    @sections = %w[MeansAssesments MeritsAssesments]
  end

  def run
    CSV.open(Rails.root.join('ccms_integration/example_payloads/NonPassportedFullMonty.csv'), 'wb') do |csv|
      @sections.each do |section_name|
        section_element = @doc.xpath("//#{section_name}").first
        entity_nodeset = section_element.xpath('AssesmentResults/AssesmentDetails/AssessmentScreens/Entity')
        entity_nodeset.each do |entity_node|
          entity_name = entity_node.xpath('EntityName').text
          attribute_blocks = entity_node.xpath('Instances/Attributes/Attribute')
          attribute_blocks.each do |block|
            attribute_name = block.xpath('Attribute').text
            response_type = block.xpath('ResponseType').text
            user_defined = block.xpath('UserDefinedInd').text
            csv << [section_name, entity_name, attribute_name, response_type, user_defined]
          end
        end
      end
    end
  end
end
