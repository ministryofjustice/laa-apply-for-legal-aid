FactoryBot.define do
  factory :child_care_assessment, class: "ProceedingMeritsTask::ChildCareAssessment" do
    proceeding
    assessed { false }

    trait :negative_assessment do
      assessed { true }
      result { false }
      details { Faker::Lorem.paragraph(sentence_count: 2) }
    end

    trait :positive_assessment do
      assessed { true }
      result { true }
      details { nil }
    end
  end
end
