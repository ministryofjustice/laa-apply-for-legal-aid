module Flow
  module Steps
    module ProviderStart
      LimitationsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_limitations_path(application) },
        forward: lambda do |application|
          if application.overriding_dwp_result? || application.non_means_tested?
            :check_provider_answers
          else
            :client_has_partners
          end
        end,
        check_answers: :check_provider_answers,
      )
    end
  end
end
