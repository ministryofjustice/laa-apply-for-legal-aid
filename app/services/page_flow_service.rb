class PageFlowService
  STEPS_FLOW = {
    legal_aid_applications: {
      path: :citizens_legal_aid_applications_path,
      forward: :information
    },
    information: {
      path: :citizens_information_path,
      back: :legal_aid_applications
    },
    accounts: {
      path: :citizens_accounts_path
    },
    additional_accounts: {
      path: :citizens_additional_accounts_path,
      back: :accounts,
      forward: :own_homes
    },
    own_homes: {
      path: :citizens_own_home_path,
      back: :additional_accounts,
      forward: ->(application) { application.own_home_no? ? :savings_and_investments : :property_values }
    },
    property_values: {
      path: :citizens_property_value_path,
      back: :own_homes,
      forward: ->(application) { application.own_home_mortgage? ? :outstanding_mortgages : :shared_ownerships }
    },
    outstanding_mortgages: {
      path: :citizens_outstanding_mortgage_path,
      back: :property_values,
      forward: :shared_ownerships
    },
    shared_ownerships: {
      path: :citizens_shared_ownership_path,
      back: ->(application) { application.own_home_mortgage? ? :outstanding_mortgages : :property_values },
      forward: ->(application) { application.shared_ownership? ? :percentage_homes : :savings_and_investments }
    },
    percentage_homes: {
      path: :citizens_percentage_home_path,
      back: :shared_ownerships,
      forward: :savings_and_investments
    },
    savings_and_investments: {
      path: :citizens_savings_and_investment_path,
      back: ->(application) do
        return :own_homes if application.own_home_no?
        return :percentage_homes if application.shared_ownership?

        :shared_ownerships
      end,
      forward: :other_assets
    },
    other_assets: {
      path: :citizens_other_assets_path,
      forward: ->(application) { application.own_capital? ? :restrictions : :check_answers },
      back: :savings_and_investments
    },
    restrictions: {
      path: :citizens_restrictions_path,
      forward: :check_answers,
      back: :other_assets
    },
    check_answers: {
      path: :citizens_check_answers_path,
      forward: :application_submitted,
      back: ->(application) { application.own_capital? ? :restrictions : :other_assets }
    },
    application_submitted: {
      path: :citizens_application_submitted_path,
      forward: nil,
      back: :check_answers
    }
  }.freeze

  def initialize(legal_aid_application, current_step)
    @legal_aid_application = legal_aid_application
    @current_step = current_step
  end

  def back_path
    path(back_step)
  end

  def forward_path
    path(forward_step)
  end

  private

  attr_reader :legal_aid_application, :current_step

  def path(step)
    path = STEPS_FLOW.dig(step, :path)
    raise ":path of step :#{step} is not defined" unless path

    path
  end

  def back_step
    @back_step ||= step(:back)
  end

  def forward_step
    @forward_step ||= step(:forward)
  end

  def step(direction)
    step = STEPS_FLOW.dig(current_step, direction)
    raise "#{direction.to_s.humanize} step of #{current_step} is not defined" unless step

    return step unless step.is_a?(Proc)

    step.call(legal_aid_application)
  end
end
