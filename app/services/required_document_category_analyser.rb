class RequiredDocumentCategoryAnalyser
  def self.call(application)
    new(application).call
  end

  def initialize(application)
    @application = application
  end

  def call
    required_document_categories = []
    required_document_categories << 'benefit_evidence' if @application.dwp_override
    required_document_categories << 'gateway_evidence' if @application.section_8_proceedings?
    @application.update!(required_document_categories: required_document_categories)
  end
end
