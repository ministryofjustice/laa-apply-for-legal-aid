module Flow
  module Flows
    class CitizenStart < FlowSteps
      STEPS = {
        legal_aid_applications: Steps::CitizenStart::LegalAidApplicationsStep,
        consents: Steps::CitizenStart::ConsentsStep,
        contact_providers: Steps::CitizenStart::ContactProviderStep,
        banks: Steps::CitizenStart::BanksStep,
        true_layer: Steps::CitizenStart::TrueLayerStep,
        gather_transactions: {
          forward: :accounts,
        },
        accounts: {
          path: ->(_) { urls.citizens_accounts_path(locale: I18n.locale) },
          forward: :additional_accounts,
          check_answers: :check_answers,
        },
        additional_accounts: {
          path: ->(_) { urls.citizens_additional_accounts_path(locale: I18n.locale) },
          forward: lambda do |application|
            application.has_offline_accounts? ? :contact_providers : :check_answers
          end,
        },
      }.freeze
    end
  end
end
