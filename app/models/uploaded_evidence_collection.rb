class UploadedEvidenceCollection < ApplicationRecord
  belongs_to :legal_aid_application
  belongs_to :provider_uploader, class_name: 'Provider', optional: true

  def original_attachments
    legal_aid_application.attachments.displayable_evidence_types
  end
end
