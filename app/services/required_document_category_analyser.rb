class RequiredDocumentCategoryAnalyser
  def self.call(application)
    new(application).call
  end

  def initialize(application)
    @application = application
  end

  def call
    required_document_categories = []
    required_document_categories << "benefit_evidence" if @application.dwp_override&.has_evidence_of_benefit?
    required_document_categories << "gateway_evidence" if @application.section_8_proceedings?
    required_document_categories << "employment_evidence" if @application.employment_evidence_required?
    # required_document_categories << "bank_statement_evidence" if @provider.permissions.include?(bank_statement_upload_permission) && @application.bank_statement_evidence_required?
    required_document_categories << "bank_statement_evidence" if @application.bank_statement_evidence_required?
    @application.update!(required_document_categories:)
  end
end
