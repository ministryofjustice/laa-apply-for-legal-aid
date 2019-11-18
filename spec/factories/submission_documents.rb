FactoryBot.define do
  factory :submission_document, class: CCMS::SubmissionDocument do
    submission
    attachment_id { SecureRandom.uuid }

    trait :new do
      status { :new }
      document_type { :statement_of_case }
      ccms_document_id { nil }
    end

    trait :id_obtained do
      status { :id_obtained }
      document_type { :statement_of_case }
      ccms_document_id { Faker::Number.number(digits: 10) }
    end

    trait :uploaded do
      status { :uploaded }
      document_type { :statement_of_case }
      ccms_document_id { Faker::Number.number(digits: 10) }
    end
  end
end
