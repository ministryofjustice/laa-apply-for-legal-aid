module Flow
  module Flows
    class ProviderCapital < FlowSteps
      STEPS = {
        capital_introductions: Steps::ProviderCapital::IntroductionsStep,
        own_homes: Steps::ProviderCapital::OwnHomesStep,
        property_details: Steps::ProviderCapital::PropertyDetailsStep,
        vehicles: {
          path: ->(application) { urls.providers_legal_aid_application_means_vehicle_path(application) },
          forward: lambda do |application|
            if application.own_vehicle?
              :vehicle_details
            elsif application.non_passported? && !application.uploading_bank_statements?
              :applicant_bank_accounts
            else
              :offline_accounts
            end
          end,
          check_answers: ->(app) { app.checking_non_passported_means? ? :check_capital_answers : :check_passported_answers },
          carry_on_sub_flow: ->(application) { application.own_vehicle? },
        },
        vehicle_details: {
          path: ->(application) { urls.new_providers_legal_aid_application_means_vehicle_detail_path(application) },
          forward: :add_other_vehicles,
          check_answers: ->(app) { app.checking_non_passported_means? ? :check_capital_answers : :check_passported_answers },
        },
        add_other_vehicles: {
          path: ->(application) { urls.providers_legal_aid_application_means_add_other_vehicles_path(application) },
          forward: lambda do |application, add_other_vehicles|
            if add_other_vehicles
              :vehicle_details
            elsif application.non_passported? && !application.uploading_bank_statements?
              :applicant_bank_accounts
            else
              :offline_accounts
            end
          end,
          check_answers: lambda do |application, add_other_vehicles|
            if add_other_vehicles
              :vehicle_details
            else
              application.checking_non_passported_means? ? :check_capital_answers : :check_passported_answers
            end
          end,
        },
        remove_vehicles: Steps::ProviderCapital::RemoveVehiclesStep,
        applicant_bank_accounts: {
          path: ->(application) { urls.providers_legal_aid_application_applicant_bank_account_path(application) },
          forward: ->(application) { application.applicant.has_partner_with_no_contrary_interest? ? :partner_bank_accounts : :savings_and_investments },
          check_answers: :check_capital_answers,
        },
        partner_bank_accounts: {
          path: ->(application) { urls.providers_legal_aid_application_partners_bank_accounts_path(application) },
          forward: :savings_and_investments,
          check_answers: :check_capital_answers,
        },
        offline_accounts: {
          path: ->(application) { urls.providers_legal_aid_application_offline_account_path(application) },
          forward: :savings_and_investments,
          check_answers: ->(application) { application.checking_non_passported_means? ? :check_capital_answers : :check_passported_answers },
        },
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
