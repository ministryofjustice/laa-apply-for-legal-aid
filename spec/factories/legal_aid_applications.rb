FactoryBot.define do
  factory :legal_aid_application, aliases: [:application] do
    trait :with_applicant do
      applicant
    end

    trait :provider_submitted do
      state { 'provider_submitted' }
    end

    trait :with_proceeding_types do
      transient do
        proceeding_types_count { 1 }
      end

      after(:create) do |application, evaluator|
        proceeding_types = if evaluator.proceeding_types.empty?
                             create_list(:proceeding_type, evaluator.proceeding_types_count)
                           else
                             evaluator.proceeding_types
                           end
        application.proceeding_types = proceeding_types
        application.save
      end
    end
  end
end
