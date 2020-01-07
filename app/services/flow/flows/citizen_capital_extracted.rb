module Flow
  module Flows
    class CitizenCapitalExtracted < FlowSteps
      STEPS = {
        own_homes: {
            path: ->(_) { urls.citizens_own_home_path },
            forward: ->(application) { application.own_home_no? ? :vehicles : :property_values },
            carry_on_sub_flow: ->(application) { !application.own_home_no? },
            check_answers: :check_answers
        },
        property_values: {
            path: ->(_) { urls.citizens_property_value_path },
            forward: ->(application) { application.own_home_mortgage? ? :outstanding_mortgages : :shared_ownerships },
            carry_on_sub_flow: true,
            check_answers: :check_answers
        },
        outstanding_mortgages: {
            path: ->(_) { urls.citizens_outstanding_mortgage_path },
            forward: :shared_ownerships,
            carry_on_sub_flow: true,
            check_answers: :check_answers
        },
        shared_ownerships: {
            path: ->(_) { urls.citizens_shared_ownership_path },
            forward: ->(application) { application.shared_ownership? ? :percentage_homes : :vehicles },
            carry_on_sub_flow: ->(application) { application.shared_ownership? },
            check_answers: :restrictions
        },
        percentage_homes: {
            path: ->(_) { urls.citizens_percentage_home_path },
            forward: :vehicles,
            check_answers: :restrictions
        },
        # Vehicle steps here (see CitizenVehicle)
        savings_and_investments: {
            path: ->(_) { urls.citizens_savings_and_investment_path },
            forward: :other_assets,
            check_answers: ->(application) { application.savings_amount? ? :restrictions : :check_answers }
        },
        other_assets: {
            path: ->(_) { urls.citizens_other_assets_path },
            forward: ->(application) { application.own_capital? ? :restrictions : :check_answers },
            check_answers: ->(application) { application.other_assets? ? :restrictions : :check_answers }
        },
        restrictions: {
            path: ->(_) { urls.citizens_restrictions_path },
            forward: :check_answers,
            check_answers: :check_answers
        }
      }.freeze
    end
  end
end
