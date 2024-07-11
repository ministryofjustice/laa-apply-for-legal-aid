module Flow
  module Steps
    module Partner
      AddOtherStateBenefitsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_partners_add_other_state_benefits_path(application) },
        forward: lambda do |_application, add_other_state_benefits|
          add_other_state_benefits ? :partner_state_benefits : :partner_regular_incomes
        end,
        check_answers: lambda do |_application, add_other_state_benefits|
          add_other_state_benefits ? :partner_state_benefits : :check_income_answers
        end,
      )
    end
  end
end
