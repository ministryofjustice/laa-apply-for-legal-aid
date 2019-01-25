module Flow
  module Flows
    module CitizenCapital
      STEPS = {
        own_homes: {
          path: ->(_, urls) { urls.citizens_own_home_path },
          back: :additional_accounts,
          forward: ->(application) { application.own_home_no? ? :savings_and_investments : :property_values },
          carry_on_sub_flow: ->(application) { !application.own_home_no? },
          check_answers: :check_answers
        },
        property_values: {
          path: ->(_, urls) { urls.citizens_property_value_path },
          back: :own_homes,
          forward: ->(application) { application.own_home_mortgage? ? :outstanding_mortgages : :shared_ownerships },
          carry_on_sub_flow: true,
          check_answers: :check_answers
        },
        outstanding_mortgages: {
          path: ->(_, urls) { urls.citizens_outstanding_mortgage_path },
          back: :property_values,
          forward: :shared_ownerships,
          carry_on_sub_flow: true,
          check_answers: :check_answers
        },
        shared_ownerships: {
          path: ->(_, urls) { urls.citizens_shared_ownership_path },
          back: ->(application) { application.own_home_mortgage? ? :outstanding_mortgages : :property_values },
          forward: ->(application) { application.shared_ownership? ? :percentage_homes : :savings_and_investments },
          carry_on_sub_flow: ->(application) { application.shared_ownership? },
          check_answers: :check_answers
        },
        percentage_homes: {
          path: ->(_, urls) { urls.citizens_percentage_home_path },
          back: :shared_ownerships,
          forward: :savings_and_investments,
          check_answers: :check_answers
        },
        savings_and_investments: {
          path: ->(_, urls) { urls.citizens_savings_and_investment_path },
          back: ->(application) do
            return :own_homes if application.own_home_no?
            return :percentage_homes if application.shared_ownership?

            :shared_ownerships
          end,
          forward: :other_assets,
          check_answers: :check_answers
        },
        other_assets: {
          path: ->(_, urls) { urls.citizens_other_assets_path },
          forward: ->(application) { application.own_capital? ? :restrictions : :check_answers },
          back: :savings_and_investments,
          check_answers: :check_answers
        },
        restrictions: {
          path: ->(_, urls) { urls.citizens_restrictions_path },
          forward: :check_answers,
          back: :other_assets,
          check_answers: :check_answers
        },
        check_answers: {
          path: ->(_, urls) { urls.citizens_check_answers_path },
          forward: :application_submitted,
          back: ->(application) { application.own_capital? ? :restrictions : :other_assets }
        },
        application_submitted: {
          path: 'citizens_application_submitted_path',
          forward: nil,
          back: :check_answers
        }
      }.freeze
    end
  end
end
