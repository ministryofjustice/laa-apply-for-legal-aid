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
    required_document_categories << "client_employment_evidence" if @application.employment_evidence_required?
    required_document_categories << "part_employ_evidence" if @application&.partner&.employment_evidence_required?
    required_document_categories << "court_application_or_order" if has_opponents_application? && !has_listed_final_hearing?
    if has_listed_final_hearing? && !has_opponents_application?
      required_document_categories << "court_order"
      required_document_categories << "expert_report"
    end
    if has_listed_final_hearing? && has_opponents_application?
      required_document_categories << "court_order"
      required_document_categories << "court_application"
      required_document_categories << "expert_report"
    end
    required_document_categories << "parental_responsibility" if has_parental_responsibility?
    @application.update!(required_document_categories:)
  end

private

  def has_listed_final_hearing?
    @application.proceedings.any? { |proceeding| listed_final_hearing?(proceeding) }
  end

  def listed_final_hearing?(proceeding)
    proceeding.final_hearings.any?(&:listed)
  end

  def has_opponents_application?
    @application.proceedings.any? { |proceeding| proceeding.opponents_application&.has_opponents_application }
  end

  def has_parental_responsibility?
    @application.proceedings.any? { |proceeding| proceeding.relationship_to_child.in?(%w[court_order parental_responsibility_agreement]) }
  end
end
