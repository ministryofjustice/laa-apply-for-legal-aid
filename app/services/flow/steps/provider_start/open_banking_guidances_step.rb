module Flow
  module Steps
    module ProviderStart
      OpenBankingGuidancesStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_open_banking_guidance_path(application) },
        forward: lambda do |_application, client_can_use_truelayer|
          client_can_use_truelayer ? :email_addresses : :bank_statements
        end,
      )
    end
  end
end
