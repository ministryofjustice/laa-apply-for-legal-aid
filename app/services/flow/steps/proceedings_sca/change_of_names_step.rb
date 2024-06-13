module Flow
  module Steps
    module ProceedingsSCA
      ChangeOfNamesStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_change_of_names_path(application) },
        forward: :has_other_proceedings,
      )
    end
  end
end
