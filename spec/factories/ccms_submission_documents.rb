FactoryBot.define do
  factory :ccms_submission_document, class: CCMS::SubmissionDocument do
    submission

    attachment_id { SecureRandom.uuid }
    status { 'uploaded' }
    document_type { 'means_report' }
    ccms_document_id { Faker::Number.number(digits: 8) }
  end
end
