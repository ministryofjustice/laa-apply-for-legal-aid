module Flow
  module Steps
    module ProviderStart
      UseCCMSUnder16sStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_use_ccms_under16s_path(application) },
      )
    end
  end
end
