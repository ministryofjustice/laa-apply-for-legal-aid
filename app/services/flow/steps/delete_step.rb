module Flow
  module Steps
    DeleteStep = Step.new(
      path: ->(application) { urls.providers_legal_aid_application_delete_path(application) },
    )
  end
end
