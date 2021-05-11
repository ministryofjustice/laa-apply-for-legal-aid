FactoryBot.define do
  factory :legal_framework_merits_task_list, class: LegalFramework::MeritsTaskList do
    legal_aid_application
    serialized_data { build(:legal_framework_serializable_merits_task_list).to_yaml }
  end
end
