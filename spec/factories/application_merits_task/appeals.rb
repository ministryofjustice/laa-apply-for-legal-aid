module ApplicationMeritsTask
  FactoryBot.define do
    factory :appeal, class: "ApplicationMeritsTask::Appeal" do
      legal_aid_application

      second_appeal { false }
      original_judge_level { nil }
      court_type { nil }
    end
  end
end
