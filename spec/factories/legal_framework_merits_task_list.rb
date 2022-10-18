FactoryBot.define do
  factory :legal_framework_merits_task_list, class: LegalFramework::MeritsTaskList do
    legal_aid_application
    serialized_data { build(:legal_framework_serializable_merits_task_list).to_yaml }

    trait :da001 do
      serialized_data { build(:legal_framework_serializable_merits_task_list, :da001).to_yaml }
    end

    trait :da001_as_defendant do
      serialized_data { build(:legal_framework_serializable_merits_task_list, :da001_as_defendant).to_yaml }
    end
  end
end
