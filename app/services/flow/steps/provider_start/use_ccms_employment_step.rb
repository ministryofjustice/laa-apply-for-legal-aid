module Flow
  module Steps
    module ProviderStart
      UseCCMSEmploymentStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_use_ccms_employment_index_path(application) },
      )
    end
  end
end
