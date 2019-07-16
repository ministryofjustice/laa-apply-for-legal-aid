class XmlExtractor
  # rubocop:disable Metrics/LineLength
  XPATHS = {
    means_assessment: '/Envelope/Body/CaseAddRQ/Case/CaseDetails/ApplicationDetails/MeansAssesments/AssesmentResults/AssesmentDetails/AssessmentScreens/Entity/Instances/Attributes/Attribute',
    merits_assessment: '/Envelope/Body/CaseAddRQ/Case/CaseDetails/ApplicationDetails/MeritsAssesments/AssesmentResults/AssesmentDetails/AssessmentScreens/Entity/Instances/Attributes/Attribute'
  }.freeze
  # rubocop:enable Metrics/LineLength

  def self.call(xml, section, attribute_name)
    new(xml, section, attribute_name).extract
  end

  def initialize(xml, section, attribute_name)
    @xml = xml
    @section = section
    @attribute_name = attribute_name
  end

  def extract
    doc = Nokogiri::XML(@xml).remove_namespaces!
    xpath = "#{XPATHS[@section]}[Attribute='#{@attribute_name}']"
    doc.xpath(xpath)
  end
end
