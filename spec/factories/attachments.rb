FactoryBot.define do
  factory :attachment do
    legal_aid_application

    attachment_type { "statement_of_case" }
    attachment_name { "statement_of_case.pdf" }

    trait :merits_report do
      attachment_type { "merits_report" }
      attachment_name { "merits_report.pdf" }
    end

    trait :means_report do
      attachment_type { "means_report" }
      attachment_name { "means_report.pdf" }
    end

    trait :bank_statement do
      attachment_type { "bank_statement_evidence" }
      sequence(:attachment_name) { |n| "bank_statement_#{n}" }
      sequence(:original_filename) { |n| "fake_bank_statement_#{n}.pdf" }
    end

    trait :bank_transaction_report do
      attachment_type { "bank_transaction_report" }
      attachment_name { "bank_transaction_report.csv" }
    end

    trait :uploaded_evidence_collection do
      attachment_type { "uncategorised" }
      attachment_name { "uploaded_evidence_collection" }
    end

    after(:create) do |attachment|
      attachment.document.attach(
        io: File.open(Rails.root.join("spec/fixtures/files/documents/hello_world.pdf")),
        filename: attachment.attachment_name,
        content_type: "application/pdf",
      )
    end
  end
end
