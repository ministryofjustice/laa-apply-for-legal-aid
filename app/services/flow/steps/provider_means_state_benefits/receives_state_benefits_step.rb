module Flow
  module Steps
    module ProviderMeansStateBenefits
      ReceivesStateBenefitsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_means_receives_state_benefits_path(application) },
        forward: lambda do |_application, options|
          options[:receives_state_benefits] ? :state_benefits : :regular_incomes
        end,
        check_answers: lambda do |application|
          if application.applicant.receives_state_benefits?
            if application.applicant.state_benefits.any?
              :add_other_state_benefits
            else
              :state_benefits
            end
          else
            :check_income_answers
          end
        end,
      )
    end
  end
end
