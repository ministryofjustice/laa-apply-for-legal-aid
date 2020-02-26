FactoryBot.define do
  factory :cfe_submission, class: CFE::Submission do
    legal_aid_application { create :legal_aid_application }
    assessment_id { SecureRandom.uuid }
  end
end
