module Flow
  module Steps
    module ProviderMerits
      FirstAppealCourtTypesStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_first_appeal_court_type_path(application) },
        forward: lambda do |application|
          Flow::MeritsLoop.forward_flow(application, :application)
        end,
        check_answers: :check_merits_answers,
      )
    end
  end
end
