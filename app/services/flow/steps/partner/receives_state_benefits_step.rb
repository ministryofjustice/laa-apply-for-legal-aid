module Flow
  module Steps
    module Partner
      ReceivesStateBenefitsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_partners_receives_state_benefits_path(application) },
        forward: lambda do |_application, receives_state_benefits|
          receives_state_benefits ? :partner_state_benefits : :partner_regular_incomes
        end,
        check_answers: lambda do |application|
          if application.partner.receives_state_benefits?
            if application.partner.state_benefits.count.positive?
              :partner_add_other_state_benefits
            else
              :partner_state_benefits
            end
          else
            :check_income_answers
          end
        end,
      )
    end
  end
end
