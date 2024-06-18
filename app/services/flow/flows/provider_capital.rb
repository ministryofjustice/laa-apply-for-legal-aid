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
        savings_and_investments: {
          path: ->(application) { urls.providers_legal_aid_application_means_savings_and_investment_path(application) },
          forward: lambda do |application|
            if application.own_capital? && application.checking_answers?
              :restrictions
            else
              :other_assets
            end
          end,
          carry_on_sub_flow: ->(application) { application.own_capital? },
          check_answers: ->(application) { application.checking_non_passported_means? ? :check_capital_answers : :check_passported_answers },
        },
        other_assets: {
          path: ->(application) { urls.providers_legal_aid_application_means_other_assets_path(application) },
          forward: lambda do |application|
            if application.own_capital?
              :restrictions
            elsif application.capture_policy_disregards?
              :policy_disregards
            else
              application.passported? ? :check_passported_answers : :check_capital_answers
            end
          end,
          carry_on_sub_flow: ->(application) { application.other_assets? },
          check_answers: ->(application) { application.checking_non_passported_means? ? :check_capital_answers : :check_passported_answers },
        },
        restrictions: {
          path: ->(application) { urls.providers_legal_aid_application_means_restrictions_path(application) },
          forward: lambda do |application|
            if application.capture_policy_disregards?
              :policy_disregards
            else
              application.passported? ? :check_passported_answers : :check_capital_answers
            end
          end,
          check_answers: ->(application) { application.provider_checking_or_checked_citizens_means_answers? ? :check_capital_answers : :check_passported_answers },
        },
        policy_disregards: {
          path: ->(application) { urls.providers_legal_aid_application_means_policy_disregards_path(application) },
          forward: ->(application) { application.passported? ? :check_passported_answers : :check_capital_answers },
          check_answers: ->(application) { application.provider_checking_or_checked_citizens_means_answers? ? :check_capital_answers : :check_passported_answers },
        },
        check_passported_answers: Steps::ProviderCapital::CheckPassportedAnswersStep,
        check_capital_answers: Steps::ProviderCapital::CheckCapitalAnswersStep,
        capital_assessment_results: Steps::ProviderCapital::CapitalAssessmentResultsStep,
        capital_income_assessment_results: Steps::ProviderCapital::CapitalIncomeAssessmentResultsStep,
        means_reports: Steps::ProviderCapital::MeansReportsStep,
      }.freeze
    end
  end
end
