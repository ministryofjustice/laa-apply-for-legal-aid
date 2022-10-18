FactoryBot.define do
  factory :allegation, class: "ApplicationMeritsTask::Allegation" do
    denies_all { true }
    legal_aid_application

    trait :with_data do
      denies_all { false }
      additional_information { "extenuating circumstances" }
    end
  end
end
