FactoryBot.define do
  factory :default_cost_limitation do
    proceeding_type

    trait :substantive do
      cost_type { 'substantive' }
      start_date { Date.parse('1970-01-01') }
      value { 25_000.0 }
    end

    trait :original_df do
      cost_type { 'delegated_functions' }
      start_date { Date.parse('1970-01-01') }
      value { 1_350.0 }
    end

    trait :revised_df do
      cost_type { 'delegated_functions' }
      start_date { Date.parse('2021-09-13') }
      value { 2_250.0 }
    end
  end
end
