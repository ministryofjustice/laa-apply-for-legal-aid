module Providers
  # Keys are controller names (as returned by `controller_name.to_sym`)
  STEPS = {
    legal_aid_applications: {
      path: :providers_legal_aid_applications_path,
      forward: :proceedings_types
      # No back: start of journey
    },
    proceedings_types: {
      path: :providers_legal_aid_application_proceedings_type_path,
      forward: :applicants,
      back: :legal_aid_applications
    },
    applicants: {
      path: :providers_legal_aid_application_applicant_path,
      forward: :address_lookups,
      back: :proceedings_types
    },
    address_lookups: {
      path: :providers_legal_aid_application_address_lookup_path,
      forward: :address_selections,
      back: :applicants
    },
    address_selections: {
      path: :providers_legal_aid_application_address_selection_path,
      forward: :check_provider_answers,
      back: :address_lookups
    },
    addresses: {
      path: :providers_legal_aid_application_address_path,
      forward: :check_provider_answers,
      back: :address_lookups
    },
    check_provider_answers: {
      path: :providers_legal_aid_application_check_provider_answers_path,
      forward: :check_benefits
      # Back determined by controller action logic
    },
    check_passported_answers: {
      path: :providers_legal_aid_application_check_passported_answers_path
      # forward TBD
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
    }
  }.freeze
end
