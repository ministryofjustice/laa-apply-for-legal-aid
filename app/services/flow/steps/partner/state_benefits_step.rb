module Flow
  module Steps
    module Partner
      StateBenefitsStep = Step.new(
        path: ->(application) { Steps.urls.new_providers_legal_aid_application_partners_state_benefit_path(application) },
        forward: :partner_add_other_state_benefits,
      )
    end
  end
end
