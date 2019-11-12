FactoryBot.define do
  factory :ccms_submission_document, class: CCMS::SubmissionDocument do
    submission

    document_id { Faker::Number.number(digits: 8) }
    status { 'uploaded' }
    document_type { 'means_report' }
    ccms_document_id { Faker::Number.number(digits: 8) }
  end
end
