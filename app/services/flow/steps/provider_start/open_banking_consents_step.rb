module Flow
  module Steps
    module ProviderStart
      OpenBankingConsentsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_open_banking_consents_path(application) },
        forward: lambda do |application|
          application.provider_received_citizen_consent? ? :open_banking_guidances : :bank_statements
        end,
      )
    end
  end
end
