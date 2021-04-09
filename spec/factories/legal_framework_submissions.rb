FactoryBot.define do
  factory :legal_framework_submission, class: LegalFramework::Submission do
    legal_aid_application { create :legal_aid_application }
    request_id { SecureRandom.uuid }
  end
end
