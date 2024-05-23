module Flow
  module Flows
    class ProviderMeansStateBenefits < FlowSteps
      STEPS = {
        receives_state_benefits: Steps::ProviderMeansStateBenefits::ReceivesStateBenefitsStep,
        state_benefits: Steps::ProviderMeansStateBenefits::StateBenefitsStep,
        add_other_state_benefits: {
          path: ->(application) { urls.providers_legal_aid_application_means_add_other_state_benefits_path(application) },
          forward: lambda do |_application, add_other_state_benefits|
            add_other_state_benefits ? :state_benefits : :regular_incomes
          end,
          check_answers: lambda do |_application, add_other_state_benefits|
            add_other_state_benefits ? :state_benefits : :check_income_answers
          end,
        },
        remove_state_benefits: Steps::ProviderMeans::RemoveStateBenefitsStep,
      }.freeze
    end
  end
end
