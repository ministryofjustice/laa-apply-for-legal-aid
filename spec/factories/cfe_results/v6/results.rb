module CFEResults
  module V6
    FactoryBot.define do
      factory :cfe_v6_result, class: "CFE::V6::Result" do
        submission factory: :cfe_submission
        legal_aid_application { submission.legal_aid_application }
        result { CFEResults::V5::MockResults.eligible.to_json }
        type { "CFE::V6::Result" }

        trait :ineligible_gross_income do
          result { CFEResults::V6::MockResults.ineligible_gross_income.to_json }
        end

        trait :ineligible_disposable_income do
          result { CFEResults::V6::MockResults.ineligible_disposable_income.to_json }
        end

        trait :ineligible_capital do
          result { CFEResults::V6::MockResults.ineligible_capital.to_json }
        end
      end
    end
  end
end
