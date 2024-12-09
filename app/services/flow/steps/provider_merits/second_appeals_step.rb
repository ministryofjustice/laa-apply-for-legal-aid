module Flow
  module Steps
    module ProviderMerits
      SecondAppealsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_second_appeal_path(application) },
        forward: lambda do |_application|
          # TODO: AP-5530
          :check_merits_answers
          # if application.second_appeal?
          #   :check_merits_answers:second_appeal_court
          # else
          #   :original_judge_level
          # end
        end,
        check_answers: :check_merits_answers,
      )
    end
  end
end
