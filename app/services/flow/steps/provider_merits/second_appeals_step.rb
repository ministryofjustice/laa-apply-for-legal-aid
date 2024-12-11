module Flow
  module Steps
    module ProviderMerits
      SecondAppealsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_second_appeal_path(application) },
        forward: lambda do |application|
          if application.appeal.second_appeal?
            # TODO: AP-5531/5532 - should go to question 3 "Which court will the second appeal be heard in?"
            Flow::MeritsLoop.forward_flow(application, :application)
          else
            :original_judge_levels
          end
        end,
        check_answers: lambda do |application|
          if application.appeal.second_appeal?
            # TODO: AP-5531/5532 - should go to question 3 "Which court will the second appeal be heard in?"
            # :appeal_court
            :check_merits_answers
          else
            :original_judge_levels
          end
        end,
      )
    end
  end
end
