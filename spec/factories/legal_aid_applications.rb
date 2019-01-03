FactoryBot.define do
  factory :legal_aid_application, aliases: [:application] do
    trait :with_applicant do
      applicant
    end

    trait :with_applicant_and_address do
      applicant { create :applicant, :with_address }
    end

    trait :with_applicant_and_address_lookup do
      applicant { create :applicant, :with_address_lookup }
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

    trait :with_own_home_mortgaged do
      own_home { 'mortgage' }
    end

    trait :with_own_home_owned_outright do
      own_home { 'owned_outright' }
    end

    trait :without_own_home do
      own_home { 'no' }
    end

    trait :with_savings_amount do
      savings_amount
    end

    trait :with_negative_benefit_check_result do
      benefit_check_result { build :benefit_check_result }
    end

    trait :with_positive_benefit_check_result do
      benefit_check_result { build :benefit_check_result, :positive }
    end

    trait :with_undetermined_benefit_check_result do
      benefit_check_result { build :benefit_check_result, :undetermined }
    end
  end
end
