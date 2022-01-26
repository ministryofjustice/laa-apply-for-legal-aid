# This validator has three uses:
# - to be a single source of truth for the valid attachment types / document category names
# - to validate the attachment_type field on Attachment model
# - to validate the name field on the DocumentCategory model
#
class DocumentCategoryValidator < ActiveModel::Validator
  # added uploaded_evidence_collection as a temp measure and also had to update the DB
  # if this is long term then the seed data needs to be updated
  VALID_DOCUMENT_TYPES = %w[
    bank_transaction_report
    benefit_evidence
    benefit_evidence_pdf
    gateway_evidence
    gateway_evidence_pdf
    means_report
    merits_report
    statement_of_case
    statement_of_case_pdf
  ].freeze

  def validate(record)
    puts ">>>>>>>>>  #{__FILE__}:#{__LINE__} <<<<<<<<<<".yellow
    return if uncategorised_evidence_attachment?(record)

    attr = case record.class.to_s
           when 'Attachment'
             :attachment_type
           when 'DocumentCategory'
             :name
           else
             raise ArgumentError, 'Unexpected record sent to DocumentCategoryValidator'
           end
    puts ">>>>>>>>>  #{__FILE__}:#{__LINE__} <<<<<<<<<<".yellow
    return if record.__send__(attr).in?(VALID_DOCUMENT_TYPES)
    puts ">>>>>>>>>  #{__FILE__}:#{__LINE__} <<<<<<<<<<".yellow
    record.errors.add attr,
                      I18n.t('activemodel.errors.models.attachment.attributes.attachment_type.invalid', attachment_type: record.__send__(attr))
  end

  def uncategorised_evidence_attachment?(record)
    puts ">>>>>>>>>  #{__FILE__}:#{__LINE__} <<<<<<<<<<".yellow
  #  evidence uploads are attached with an attachment_typeof evidence upload collection before they are categorised
  # which is valid, but is not in the list of valid document types
  record.is_a?(Attachment) && record.attachment_type=='uncategorised'
  end
end
