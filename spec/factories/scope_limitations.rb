FactoryBot.define do
  factory :scope_limitation do
    sequence(:code) { |n| format('AA%<number>03d', number: n) }
    meaning { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    substantive { true }
    delegated_functions { false }

    trait :substantive do
      substantive { true }
    end

    trait :delegated_functions do
      delegated_functions { true }
    end

    transient do
      joined_proceeding_type { create :proceeding_type }
    end

    trait :substantive_default do
      substantive { true }
      after(:create) do |scope_limitation, evaluator|
        create :proceeding_type_scope_limitation,
               substantive_default: true,
               delegated_functions_default: false,
               scope_limitation: scope_limitation,
               proceeding_type: evaluator.joined_proceeding_type
      end
    end

    trait :delegated_functions_default do
      delegated_functions { true }
      after(:create) do |scope_limitation, evaluator|
        create :proceeding_type_scope_limitation,
               substantive_default: false,
               delegated_functions_default: true,
               scope_limitation: scope_limitation,
               proceeding_type: evaluator.joined_proceeding_type
      end
    end

    trait :with_real_data do
      code { 'AA009' }
      meaning { 'Warrant of arrest FLA' }
      description { 'As to an order under Part IV Family Law Act 1996 limited to an application for the issue of a warrant of arrest.' }
      substantive { true }
      delegated_functions { true }
    end
  end
end
