class DocumentCategoryAnalyser
  def self.call(application)
    new(application).call
  end

  def initialize(application)
    @application = application
  end

  def call
    allowed_document_categories = []
    allowed_document_categories << "benefit_evidence" if @application.dwp_override&.has_evidence_of_benefit?
    allowed_document_categories << "gateway_evidence" if @application.section_8_proceedings?
    allowed_document_categories << "client_employment_evidence" if @application.employment_evidence_required?
    allowed_document_categories << "part_employ_evidence" if @application&.partner&.employment_evidence_required?
    allowed_document_categories << "court_application_or_order" if has_opponents_application? && !has_listed_final_hearing?

    if has_listed_final_hearing? && !has_opponents_application?
      allowed_document_categories << "court_order"
      allowed_document_categories << "expert_report"
    end

    if has_listed_final_hearing? && has_opponents_application?
      allowed_document_categories << "court_order"
      allowed_document_categories << "court_application"
      allowed_document_categories << "expert_report"
    end

    allowed_document_categories << "parental_responsibility" if has_parental_responsibility?
    allowed_document_categories << "local_authority_assessment" if has_local_authority_assessment?
    allowed_document_categories << "plf_court_order" if @application.plf_court_order?

    if @application.public_law_family_proceedings?
      allowed_document_categories << "grounds_of_appeal"
      allowed_document_categories << "counsel_opinion"
      allowed_document_categories << "judgement"
    end

    @application.update!(allowed_document_categories:)
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
    @application.applicant.relationship_to_children.in?(%w[court_order parental_responsibility_agreement])
  end

  def has_local_authority_assessment?
    @application.proceedings.any? { |proceeding| proceeding.child_care_assessment&.assessed? }
  end
end
