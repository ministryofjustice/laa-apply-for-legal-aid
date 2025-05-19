module Flow
  module Steps
    module ProviderMerits
      StatementOfCasesStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_statement_of_case_path(application) },
        forward: lambda { |application, options|
          options[:uploaded] ? :statement_of_case_uploads : Flow::MeritsLoop.forward_flow(application, :application)
        },
        check_answers: lambda { |_application, options|
          options[:uploaded] ? :statement_of_case_uploads : :check_merits_answers
        },
      )
    end
  end
end
