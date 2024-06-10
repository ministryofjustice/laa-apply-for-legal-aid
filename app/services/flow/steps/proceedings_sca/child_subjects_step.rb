module Flow
  module Steps
    module ProceedingsSCA
      ChildSubjectsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_child_subject_path(application) },
        forward: :has_other_proceedings,
      )
    end
  end
end
