module Flow
  module Steps
    module ProviderDependants
      HasOtherDependantsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_means_has_other_dependants_path(application) },
        forward: lambda { |_application, has_other_dependant|
          has_other_dependant ? :dependants : :check_income_answers
        },
        check_answers: lambda { |_application, has_other_dependant|
          has_other_dependant ? :dependants : :check_income_answers
        },
      )
    end
  end
end
