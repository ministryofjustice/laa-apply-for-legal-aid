class UploadedEvidenceCollection < ApplicationRecord
  belongs_to :legal_aid_application
  belongs_to :provider_uploader, class_name: 'Provider', optional: true

  def original_attachments
    legal_aid_application.attachments.uploadable_evidence_types
  end

  def pdf_attachments
    legal_aid_application.attachments.evidence_upload_pdf
  end
end
