module Flow
  module Steps
    module ProviderMerits
      OriginalJudgeLevelsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_original_judge_level_path(application) },
        forward: lambda do |application|
          Flow::MeritsLoop.forward_flow(application, :application)
          # TODO: AP-5531/5532 - should goto question 4 or Next question
          # NOTE: should/could use same form but setup with different options/content for "second" or "first" appeal court
          #
          # if application.appeal.original_judge_level.in?(%i[family_panel_magistrates deputy_district_judge district_judge])
          #   :appeal_court
          # elsif application.appeal.original_judge_level.in?(%i[recorder_circuit_judge high_court_judge])
          #   :second_appeal_court
          # else
          #   Flow::MeritsLoop.forward_flow(application, :application)
          # end
          #
          # OR
          #
          # if application.appeal.original_judge_level.present?
          #   :appeal_court # And let that form handle difference between 3 and 4 based on second_appeal true (question 3) or false (question 4)
          # else
          #   Flow::MeritsLoop.forward_flow(application, :application)
          # end
        end,
        # TODO: AP-5531/5532 - should goto question 4 or Next question
        check_answers: :check_merits_answers,
      )
    end
  end
end
