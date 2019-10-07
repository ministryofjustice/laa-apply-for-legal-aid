FactoryBot.define do
  factory :cfe_result, class: CFE::Result do
    submission { create :cfe_submission }
    legal_aid_application { submission.legal_aid_application }
    result do
      {
        a: 'A',
        b: 'B'
      }.to_json
    end
  end
end
