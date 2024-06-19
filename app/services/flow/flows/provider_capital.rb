module Flow
  module Flows
    class ProviderCapital < FlowSteps
      STEPS = {
        capital_introductions: Steps::ProviderCapital::IntroductionsStep,
        own_homes: Steps::ProviderCapital::OwnHomesStep,
        property_details: Steps::ProviderCapital::PropertyDetailsStep,
        vehicles: Steps::ProviderCapital::VehiclesStep,
        vehicle_details: Steps::ProviderCapital::VehicleDetailsStep,
        add_other_vehicles: Steps::ProviderCapital::AddOtherVehiclesStep,
        remove_vehicles: Steps::ProviderCapital::RemoveVehiclesStep,
        applicant_bank_accounts: Steps::ProviderCapital::ApplicantBankAccountsStep,
        partner_bank_accounts: Steps::ProviderCapital::PartnerBankAccountsStep,
        offline_accounts: Steps::ProviderCapital::OfflineAccountsStep,
        savings_and_investments: Steps::ProviderCapital::SavingsAndInvestmentsStep,
        other_assets: Steps::ProviderCapital::OtherAssetsStep,
        restrictions: Steps::ProviderCapital::RestrictionsStep,
        policy_disregards: Steps::ProviderCapital::PolicyDisregardsStep,
        check_passported_answers: Steps::ProviderCapital::CheckPassportedAnswersStep,
        check_capital_answers: Steps::ProviderCapital::CheckCapitalAnswersStep,
        capital_assessment_results: Steps::ProviderCapital::CapitalAssessmentResultsStep,
        capital_income_assessment_results: Steps::ProviderCapital::CapitalIncomeAssessmentResultsStep,
        means_reports: Steps::ProviderCapital::MeansReportsStep,
      }.freeze
    end
  end
end
