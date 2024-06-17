module Flow
  module Steps
    module ProviderIncome
      FullEmploymentDetailsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_means_full_employment_details_path(application) },
        forward: lambda do |application|
          if application.uploading_bank_statements?
            :receives_state_benefits
          else
            :identify_types_of_incomes
          end
        end,
        check_answers: :check_income_answers,
      )
    end
  end
end
