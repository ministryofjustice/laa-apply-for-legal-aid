class UploadedEvidenceCollection < ApplicationRecord
  belongs_to :legal_aid_application
  belongs_to :provider_uploader, class_name: 'Provider', optional: true

  def original_attachments
    # this will only work if we label them as valid submit to ccms types
    legal_aid_application.attachments.uploadable_evidence_types
    # so we need to include all types that are added on this page
    # legal_aid_application.attachments.uploaded_evidence_collection
  end

  def pdf_attachments
    legal_aid_application.attachments.evidence_upload_pdf
  end
end
