module Flow
  module Flows
    class CitizenStart < FlowSteps
      STEPS = {
        legal_aid_applications: Steps::CitizenStart::LegalAidApplicationsStep,
        consents: Steps::CitizenStart::ConsentsStep,
        contact_providers: Steps::CitizenStart::ContactProviderStep,
        banks: Steps::CitizenStart::BanksStep,
        true_layer: Steps::CitizenStart::TrueLayerStep,
        gather_transactions: Steps::CitizenStart::GatherTransactionsStep,
        accounts: Steps::CitizenStart::AccountsStep,
        additional_accounts: Steps::CitizenStart::AdditionalAccountsStep,
      }.freeze
    end
  end
end
