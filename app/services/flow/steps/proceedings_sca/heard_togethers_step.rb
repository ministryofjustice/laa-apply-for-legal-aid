module Flow
  module Steps
    module ProceedingsSCA
      HeardTogethersStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_heard_togethers_path(application) },
        forward: ->(_application, heard_together) { heard_together ? :has_other_proceedings : :proceedings_sca_heard_as_alternatives },
      )
    end
  end
end
