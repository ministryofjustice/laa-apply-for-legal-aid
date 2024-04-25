module Flow
  module Steps
    module Partner
      RemoveStateBenefitsStep = Step.new(
        path: ->(application, transaction) { Steps.urls.providers_legal_aid_application_partners_remove_state_benefit_path(application, transaction) },
        forward: lambda do |_application, partner_has_any_state_benefits|
          partner_has_any_state_benefits ? :partner_add_other_state_benefits : :partner_receives_state_benefits
        end,
      )
    end
  end
end
