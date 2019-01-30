# rubocop:disable ModuleLength
module Providers
  # Keys are controller names (as returned by `controller_name.to_sym`)
  STEPS = {
    legal_aid_applications: {
      path: :providers_legal_aid_applications_path,
      forward: :applicants
      # No back: start of journey
    },
    applicants: {
      path: :providers_legal_aid_application_applicant_path,
      forward: :address_lookups,
      back: :legal_aid_applications
    },
    address_lookups: {
      path: :providers_legal_aid_application_address_lookup_path,
      forward: :address_selections,
      back: :applicants
    },
    address_selections: {
      path: :providers_legal_aid_application_address_selection_path,
      forward: :proceedings_types,
      back: :address_lookups
    },
    addresses: {
      path: :providers_legal_aid_application_address_path,
      forward: :proceedings_types,
      back: :address_lookups
    },
    proceedings_types: {
      path: :providers_legal_aid_application_proceedings_types_path,
      forward: :check_provider_answers,
      back: :addresses
      # Back determined by controller action logic
    },
    check_provider_answers: {
      path: :providers_legal_aid_application_check_provider_answers_path,
      forward: :check_benefits,
      back: :proceedings_types
    },
    check_passported_answers: {
      path: :providers_legal_aid_application_check_passported_answers_path,
      forward: :client_received_legal_helps
      # back: determined by controller action
    },
    check_benefits: {
      path: :providers_legal_aid_application_check_benefits_path,
      # forward: :providers_legal_aid_application_check_provider_answers_path,
      back: :check_provider_answers
    },
    online_bankings: {
      path: :providers_legal_aid_application_online_banking_path,
      forward: :about_the_financial_assessments,
      back: :check_benefits
    },
    about_the_financial_assessments: {
      path: :providers_legal_aid_application_about_the_financial_assessment_path,
      back: :online_bankings
    },
    restrictions: {
      path: :providers_legal_aid_application_restrictions_path,
      forward: :check_passported_answers,
      back: :other_assets
    },
    percentage_homes: {
      path: :providers_legal_aid_application_percentage_home_path,
      forward: :savings_and_investments,
      back: :shared_ownerships
    },
    savings_and_investments: {
      path: :providers_legal_aid_application_savings_and_investment_path,
      forward: :other_assets
      # back: defined in controller
    },
    own_homes: {
      path: :providers_legal_aid_application_own_home_path,
      # forward: determined by controller action logic
      back: :check_benefits
    },
    property_values: {
      path: :providers_legal_aid_application_property_value_path,
      # forward: determined in controller,
      back: :own_homes
    },
    outstanding_mortgages: {
      path: :providers_legal_aid_application_outstanding_mortgage_path,
      forward: :shared_ownerships,
      back: :property_values
    },
    shared_ownerships: {
      path: :providers_legal_aid_application_shared_ownership_path
      # Forward defined by controller
      # Back defined by controller
    },
    other_assets: {
      path: :providers_legal_aid_application_other_assets_path,
      # Forward defined by controller
      back: :savings_and_investments
    },
    client_received_legal_helps: {
      path: :providers_legal_aid_application_client_received_legal_help_path,
      forward: :proceedings_before_the_courts,
      back: :check_passported_answers
    },
    proceedings_before_the_courts: {
      path: :providers_legal_aid_application_proceedings_before_the_court_path,
      # TODO: forward TBD, client_received_legal_helps is just a placeholder
      forward: :statement_of_cases,
      back: :client_received_legal_helps
    },
    statement_of_cases: {
      path: :providers_legal_aid_application_statement_of_case_path,
      forward: :client_received_legal_helps,
      back: :proceedings_before_the_courts
    },
    estimated_legal_costs: {
      path: :providers_legal_aid_application_estimated_legal_costs_path,
      forward: :success_prospects,
      # TODO: fix back when back page is implemented
      back: :estimated_legal_costs
    },
    merits_declarations: {
      path: :providers_legal_aid_application_merits_declaration_path,
      # TO DO this will point to merits_check_answers when implemented
      forward: :merits_declarations,
      # TO DO this will point to prospects_of_success when implemented
      back: :merits_declarations
    },
    success_prospects: {
      path: :providers_legal_aid_application_success_prospects_path,
      forward: :success_prospects,
      back: :estimated_legal_costs
    }
  }.freeze
end
# rubocop:enable ModuleLength
