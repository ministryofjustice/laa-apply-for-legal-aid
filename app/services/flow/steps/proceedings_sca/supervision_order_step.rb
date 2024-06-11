module Flow
  module Steps
    module ProceedingsSCA
      SupervisionOrderStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_supervision_orders_path(application) },
        forward: :has_other_proceedings,
      )
    end
  end
end
