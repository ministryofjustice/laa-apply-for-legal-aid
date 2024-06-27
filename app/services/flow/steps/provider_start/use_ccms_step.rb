module Flow
  module Steps
    module ProviderStart
      UseCCMSStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_use_ccms_path(application) },
      )
    end
  end
end
