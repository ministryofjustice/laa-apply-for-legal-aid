class BankStatementUpload < ApplicationRecord
  belongs_to :legal_aid_application
  belongs_to :provider_uploader, class_name: "Provider", optional: true

  def original_attachments
    legal_aid_application.attachments.client_bank_statement
  end

private

  def error_path
    ".activemodel.errors.models.bank_statement_upload.attributes.original_file"
  end
end
