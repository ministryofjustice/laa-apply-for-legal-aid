module Flow
  module Steps
    module ProviderMerits
      SecondAppealsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_second_appeal_path(application) },
        forward: lambda do |application|
          if application.appeal.second_appeal?
            :second_appeal_court_types
          else
            :original_judge_levels
          end
        end,
        check_answers: lambda do |application|
          if application.appeal.second_appeal?
            :second_appeal_court_types
          else
            :original_judge_levels
          end
        end,
      )
    end
  end
end
