module Flow
  module Steps
    module Partner
      UseCCMSEmploymentStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_partners_use_ccms_employment_index_path(application) },
      )
    end
  end
end
