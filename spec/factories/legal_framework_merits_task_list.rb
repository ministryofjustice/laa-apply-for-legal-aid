FactoryBot.define do
  factory :legal_framework_merits_task_list, class: "LegalFramework::MeritsTaskList" do
    legal_aid_application
    serialized_data { build(:legal_framework_serializable_merits_task_list).to_yaml }

    trait :da001 do
      serialized_data { build(:legal_framework_serializable_merits_task_list, :da001).to_yaml }
    end

    trait :da001_da004_se014 do
      serialized_data { build(:legal_framework_serializable_merits_task_list, :da001_da004_se014).to_yaml }
    end

    trait :da001_as_defendant do
      serialized_data { build(:legal_framework_serializable_merits_task_list, :da001_as_defendant).to_yaml }
    end

    trait :da001_as_defendant_and_child_section_8 do
      serialized_data { build(:legal_framework_serializable_merits_task_list, :da001_as_defendant_and_child_section_8).to_yaml }
    end

    trait :da001_and_se004 do
      serialized_data { build(:legal_framework_serializable_merits_task_list, :da001_and_se004).to_yaml }
    end

    trait :da001_as_defendant_se003 do
      serialized_data { build(:legal_framework_serializable_merits_task_list, :da001_as_defendant_se003).to_yaml }
    end

    trait :da001_and_child_section_8_with_delegated_functions do
      serialized_data { build(:legal_framework_serializable_merits_task_list, :da001_and_child_section_8_with_delegated_functions).to_yaml }
    end

    trait :da002_as_applicant do
      serialized_data { build(:legal_framework_serializable_merits_task_list, :da002_as_applicant).to_yaml }
    end

    trait :da002_da006_as_applicant do
      serialized_data { build(:legal_framework_serializable_merits_task_list, :da002_da006_as_applicant).to_yaml }
    end

    trait :da001_da005_as_applicant do
      serialized_data { build(:legal_framework_serializable_merits_task_list, :da001_da005_as_applicant).to_yaml }
    end

    trait :pb003_pb059 do
      serialized_data { build(:legal_framework_serializable_merits_task_list, :pb003_pb059).to_yaml }
    end

    trait :broken_opponent do
      serialized_data { build(:legal_framework_serializable_merits_task_list, :broken_opponent).to_yaml }
    end
  end
end
