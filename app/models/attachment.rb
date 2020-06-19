class Attachment < ApplicationRecord
  belongs_to :legal_aid_application
  has_one_attached :document

  enum(
    attachment_type: {
      statement_of_case: 'statement_of_case'.freeze,
      statement_of_case_pdf: 'statement_of_case_pdf'.freeze,
      merits_report: 'merits_report'.freeze,
      means_report: 'means_report'.freeze,
      bank_transaction_report: 'bank_transaction_report'.freeze
    },
    _prefix: false
  )
end
