module Flow
  module Steps
    module ProviderMerits
      OriginalJudgeLevelsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_original_judge_level_path(application) },
        forward: lambda do |application|
          if application.appeal.original_judge_level.in?(%w[recorder_circuit_judge high_court_judge])
            :first_appeal_court_types
          else
            Flow::MeritsLoop.forward_flow(application, :application)
          end
        end,
        check_answers: lambda do |application|
          if application.appeal.original_judge_level.in?(%w[recorder_circuit_judge high_court_judge])
            :first_appeal_court_types
          else
            :check_merits_answers
          end
        end,
      )
    end
  end
end
