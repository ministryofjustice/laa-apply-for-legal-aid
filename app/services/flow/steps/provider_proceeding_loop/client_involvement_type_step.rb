module Flow
  module Steps
    module ProviderProceedingLoop
      ClientInvolvementTypeStep = Step.new(
        path: lambda do |application|
          proceeding = Flow::ProceedingLoop.next_proceeding(application)
          Steps.urls.providers_legal_aid_application_client_involvement_type_path(application, proceeding)
        end,
        forward: :delegated_functions,
        carry_on_sub_flow: true,
        check_answers: :check_provider_answers,
      )
    end
  end
end
