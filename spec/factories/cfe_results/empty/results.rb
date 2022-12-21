module CFEResults
  module Empty
    FactoryBot.define do
      factory :cfe_empty_result, class: "CFE::Empty::Result" do
        submission factory: :cfe_submission
        legal_aid_application { submission.legal_aid_application }
        result { CFEResults::Empty::MockResults.no_assessment.to_json }
        type { "CFE::Empty::Result" }
      end
    end
  end
end
