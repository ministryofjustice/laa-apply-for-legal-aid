module Flow
  module Steps
    module ProviderMerits
      SecondAppealsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_second_appeal_path(application) },
        forward: lambda do |application|
          # TODO: AP-5530 - should got to court type or judge level question
          Flow::MeritsLoop.forward_flow(application, :application)
          # if application.second_appeal?
          #   :second_appeal_court
          # else
          #   :original_judge_level
          # end
        end,
        check_answers: :check_merits_answers,
      )
    end
  end
end
