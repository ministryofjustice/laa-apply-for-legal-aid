FactoryBot.define do
  factory :legal_framework_serializable_merits_task, class: LegalFramework::SerializableMeritsTask do
    initialize_with { new(name, dependencies: dependencies) }

    dependencies { [:application_children] }
    name { :proceeding_children }
  end
end
