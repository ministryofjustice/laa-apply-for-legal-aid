module Flow
  module Flows
    class ProviderMeansStateBenefits < FlowSteps
      STEPS = {
        receives_state_benefits: {
          path: ->(application) { urls.providers_legal_aid_application_means_receives_state_benefits_path(application) },
          forward: lambda do |_application, receives_state_benefits|
            receives_state_benefits ? :state_benefits : :regular_incomes
          end,
          check_answers: lambda do |application|
            if application.applicant.receives_state_benefits?
              if application.applicant.state_benefits.count.positive?
                :add_other_state_benefits
              else
                :state_benefits
              end
            else
              :check_income_answers
            end
          end,
        },
        state_benefits: {
          path: ->(application) { urls.new_providers_legal_aid_application_means_state_benefit_path(application) },
          forward: :add_other_state_benefits,
        },
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
