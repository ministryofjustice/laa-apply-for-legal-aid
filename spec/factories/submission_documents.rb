FactoryBot.define do
  factory :submission_document, class: CCMS::SubmissionDocument do
    submission

    trait :new do
      document_id { Faker::Number.number(digits: 10) }
      status { :new }
      document_type { :statement_of_case }
      ccms_document_id { nil }
    end

    trait :id_obtained do
      document_id { Faker::Number.number(digits: 10) }
      status { :id_obtained }
      document_type { :statement_of_case }
      ccms_document_id { Faker::Number.number(digits: 10) }
    end

    trait :uploaded do
      document_id { Faker::Number.number(digits: 10) }
      status { :uploaded }
      document_type { :statement_of_case }
      ccms_document_id { Faker::Number.number(digits: 10) }
    end
  end
end
