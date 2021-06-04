class GatewayEvidence < ApplicationRecord
  belongs_to :legal_aid_application
  belongs_to :provider_uploader, class_name: 'Provider', optional: true

  def original_attachments
    legal_aid_application.attachments.gateway_evidence
  end

  def pdf_attachments
    legal_aid_application.attachments.gateway_evidence_pdf
  end
end
