class UploadedEvidenceCollection < ApplicationRecord
  belongs_to :legal_aid_application
  belongs_to :provider_uploader, class_name: 'Provider', optional: true

  def original_attachments
    legal_aid_application.attachments.displayable_evidence_types
  end

  def application_evidence_types
    legal_aid_application.required_document_categories
  end

  def mandatory_evidence_types
    DocumentCategory.where(name: application_evidence_types, mandatory: true).pluck(:name)
  end

  def categorised_evidence_types
    original_attachments.pluck(:attachment_type).uniq
  end
end
