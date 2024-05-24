module Flow
  module Steps
    module ProviderMeansStateBenefits
      StateBenefitsStep = Step.new(
        path: ->(application) { Steps.urls.new_providers_legal_aid_application_means_state_benefit_path(application) },
        forward: :add_other_state_benefits,
      )
    end
  end
end
