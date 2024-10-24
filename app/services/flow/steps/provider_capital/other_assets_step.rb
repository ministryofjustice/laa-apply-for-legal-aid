module Flow
  module Steps
    module ProviderCapital
      OtherAssetsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_means_other_assets_path(application) },
        forward: lambda do |application|
          if application.own_capital?
            :restrictions
          elsif application.capture_policy_disregards?
            Setting.means_test_review_a? ? :mandatory_disregards : :policy_disregards
          else
            application.passported? ? :check_passported_answers : :check_capital_answers
          end
        end,
        carry_on_sub_flow: ->(application) { application.other_assets? },
        check_answers: ->(application) { application.checking_non_passported_means? ? :check_capital_answers : :check_passported_answers },
      )
    end
  end
end
