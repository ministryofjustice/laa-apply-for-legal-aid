module Providers
  class CheckBenefitsController < BaseController
    include Providers::ApplicationDependable
    include Providers::Steppable

    before_action :set_current_step

    def index
      legal_aid_application.add_benefit_check_result unless legal_aid_application.benefit_check_result

      next_step
    end

    private

    def next_step
      # TODO: implement next_step logic
      # next step depends on the result of the benefit_check.
      # If result is positive, go to the email address prompt
      # If not, go to the "online banking" page
      # We could implement this by modififying @current_step
      # by setting it to either :check_benefits_true or :check_benefits_false for example
      # and set the appropriate next step in the Steppable module.
      # That way, we define the condition here
      # rather than having to implement conditionnal steps in the Steppable module

      @next_step_link = action_for_next_step(options: { application: legal_aid_application })
    end

    def set_current_step
      @current_step = :check_benefits
    end
  end
end
