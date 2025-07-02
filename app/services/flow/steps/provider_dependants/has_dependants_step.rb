module Flow
  module Steps
    module ProviderDependants
      HasDependantsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_means_has_dependants_path(application) },
        forward: lambda do |application|
          if application.has_dependants?
            :dependants
          else
            :check_income_answers
          end
        end,
        check_answers: lambda do |application|
          if application.has_dependants?
            if application.dependants.any?
              :has_other_dependants
            else
              :dependants
            end
          else
            :check_income_answers
          end
        end,
      )
    end
  end
end
