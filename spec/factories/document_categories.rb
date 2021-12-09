FactoryBot.define do
  factory :document_category do
    name { 'document_name' }
    submit_to_ccms { false }
    ccms_document_type { 'document_type' }
    display_on_evidence_upload { false }
    mandatory { false }
  end

  trait :with_real_data do
    name { 'bank_transaction_report' }
    submit_to_ccms { true }
    ccms_document_type { 'BSTMT' }
  end
end
