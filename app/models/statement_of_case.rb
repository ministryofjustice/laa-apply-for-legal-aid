class StatementOfCase < ApplicationRecord
  belongs_to :legal_aid_application
  belongs_to :provider_uploader, class_name: 'Provider', optional: true
  before_create :attachments_exists?

  def original_attachments
    legal_aid_application.attachments.statement_of_case
  end

  def attachments_exists?
    legal_aid_application.attachments.present?
  end

  def pdf_attachments
    legal_aid_application.attachments.statement_of_case_pdf
  end
end
