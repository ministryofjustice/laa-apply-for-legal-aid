module Flow
  module Steps
    CheckClientDetailsStep = Step.new(
      ->(application) { urls.providers_legal_aid_application_check_client_details_path(application) },
      :received_benefit_confirmations,
      nil,
    )
  end
end
