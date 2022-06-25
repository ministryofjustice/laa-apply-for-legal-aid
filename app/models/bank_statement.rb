class BankStatement < ApplicationRecord
  belongs_to :legal_aid_application
  belongs_to :provider_uploader, class_name: "Provider", optional: true

  def original_attachments
    legal_aid_application.attachments.bank_statement_evidence
  end

private

  def error_path
    ".activemodel.errors.models.bank_statement.attributes.original_file"
  end
end
