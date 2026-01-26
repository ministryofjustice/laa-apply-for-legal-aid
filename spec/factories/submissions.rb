FactoryBot.define do
  factory :submission, class: "CCMS::Submission" do
    legal_aid_application { association(:legal_aid_application, merits_submitted_by: create(:provider)) }

    sequence(:case_ccms_reference) { |n| sprintf("300000%<number>06d", number: n) }

    trait :case_ref_obtained do
      aasm_state { "case_ref_obtained" }
    end

    trait :applicant_submitted do
      aasm_state { "applicant_submitted" }
    end

    trait :applicant_ref_obtained do
      aasm_state { "applicant_ref_obtained" }
    end

    trait :case_submitted do
      aasm_state { "case_submitted" }
    end

    trait :case_created do
      aasm_state { "case_created" }
    end

    trait :document_ids_obtained do
      aasm_state { "document_ids_obtained" }
      after :create do |submission|
        create(:submission_document, :id_obtained, submission:)
      end
    end
  end
end
