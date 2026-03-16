module Flow
  module Steps
    module Partner
      MultipleEmploymentsInterruptsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_partners_multiple_employments_interrupt_path(application) },
      )
    end
  end
end
