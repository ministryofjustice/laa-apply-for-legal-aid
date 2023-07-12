# This validator has three uses:
# - to be a single source of truth for the valid attachment types / document category names
# - to validate the attachment_type field on Attachment model
# - to validate the name field on the DocumentCategory model
#
class DocumentCategoryValidator < ActiveModel::Validator
  VALID_DOCUMENT_TYPES = %w[
    bank_transaction_report
    benefit_evidence
    benefit_evidence_pdf
    employment_evidence
    employment_evidence_pdf
    gateway_evidence
    gateway_evidence_pdf
    means_report
    merits_report
    statement_of_case
    statement_of_case_pdf
    bank_statement_evidence
    bank_statement_evidence_pdf
    court_application
    court_application_pdf
    court_order
    court_order_pdf
    expert_report
    expert_report_pdf
    court_application_or_order
    court_application_or_order_pdf
    partner_bank_statement_evidence
    partner_bank_statement_evidence_pdf
  ].freeze

  def validate(record)
    return if uncategorised_evidence_attachment?(record)

    attr = case record.class.to_s
           when "Attachment"
             :attachment_type
           when "DocumentCategory"
             :name
           else
             raise ArgumentError, "Unexpected record sent to DocumentCategoryValidator"
           end

    return if record.__send__(attr).in?(VALID_DOCUMENT_TYPES)

    record.errors.add attr,
                      I18n.t("activemodel.errors.models.attachment.attributes.attachment_type.invalid", attachment_type: record.__send__(attr))
  end

  def uncategorised_evidence_attachment?(record)
    record.is_a?(Attachment) && record.attachment_type == "uncategorised"
  end
end
