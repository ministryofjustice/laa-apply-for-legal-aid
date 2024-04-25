module Flow
  module Steps
    module ProviderMeans
      RemoveStateBenefitsStep = Step.new(
        path: ->(application, transaction) { Steps.urls.providers_legal_aid_application_means_remove_state_benefit_path(application, transaction) },
        forward: lambda do |_application, applicant_has_any_state_benefits|
          applicant_has_any_state_benefits ? :add_other_state_benefits : :receives_state_benefits
        end,
      )
    end
  end
end
