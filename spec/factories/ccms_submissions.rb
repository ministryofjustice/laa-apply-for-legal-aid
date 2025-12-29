FactoryBot.define do
  factory :ccms_submission, class: "CCMS::Submission" do
    legal_aid_application

    trait :initialised do
      aasm_state { "initialised" }
    end

    trait :lead_application_pending do
      case_ccms_reference { Faker::Number.number(digits: 12) }
      aasm_state { "lead_application_pending" }

      after(:create) do |submission|
        create(:ccms_submission_history, submission:)
      end
    end

    trait :case_ref_obtained do
      case_ccms_reference { Faker::Number.number(digits: 12) }
      aasm_state { "case_ref_obtained" }

      after(:create) do |submission|
        create(:ccms_submission_history, submission:)
      end
    end

    trait :applicant_submitted do
      case_ccms_reference { Faker::Number.number(digits: 12) }
      aasm_state { "applicant_submitted" }

      after(:create) do |submission|
        create(:ccms_submission_history, submission:)
      end
    end

    trait :applicant_ref_obtained do
      case_ccms_reference { Faker::Number.number(digits: 12) }
      applicant_ccms_reference { Faker::Number.number(digits: 8) }
      aasm_state { "applicant_ref_obtained" }

      after(:create) do |submission|
        create(:ccms_submission_history, submission:)
      end
    end

    trait :document_ids_obtained do
      case_ccms_reference { Faker::Number.number(digits: 12) }
      applicant_ccms_reference { Faker::Number.number(digits: 8) }
      aasm_state { "document_ids_obtained" }

      after(:create) do |submission|
        create(:ccms_submission_history, submission:)
        create(:ccms_submission_document, submission:)
      end
    end

    trait :case_submitted do
      case_ccms_reference { Faker::Number.number(digits: 12) }
      applicant_ccms_reference { Faker::Number.number(digits: 8) }
      aasm_state { "case_submitted" }

      after(:create) do |submission|
        create(:ccms_submission_history, submission:)
        create(:ccms_submission_document, submission:)
      end
    end

    trait :case_created do
      case_ccms_reference { Faker::Number.number(digits: 12) }
      applicant_ccms_reference { Faker::Number.number(digits: 8) }
      aasm_state { "case_created" }

      after(:create) do |submission|
        create(:ccms_submission_history, submission:)
        create(:ccms_submission_document, submission:)
      end
    end

    trait :case_completed do
      case_ccms_reference { Faker::Number.number(digits: 12) }
      applicant_ccms_reference { Faker::Number.number(digits: 8) }
      aasm_state { "completed" }

      after(:create) do |submission|
        create(:ccms_submission_history, :with_xml, to_state: "case_submitted", submission:)
        create(:ccms_submission_document, submission:)
      end
    end
  end
end
