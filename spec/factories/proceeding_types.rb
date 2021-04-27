FactoryBot.define do
  factory :proceeding_type do
    association :default_level_of_service, factory: %i[service_level with_real_data]

    sequence(:code) { |n| format('PR%<number>04d', number: n) }
    ccms_code { 'PBM23' }
    meaning { 'Meaning' }
    name { 'name' }
    description { 'Description' }
    ccms_category_law { 'Category law' }
    ccms_category_law_code { 'Category law code' }
    ccms_matter { 'Matter' }
    ccms_matter_code { 'Matter code' }
    default_service_level_id { create(:service_level).id }
    default_cost_limitation_delegated_functions { 1 }
    default_cost_limitation_substantive { 2 }
    involvement_type_applicant { false }
    additional_search_terms { nil }

    trait :with_real_data do
      code { 'PR0208' }
      ccms_code { 'DA001' }
      meaning { 'Inherent jurisdiction high court injunction' }
      name { 'inherent_jurisdiction_high_court_injunction' }
      description { 'to be represented on an application for an injunction, order or declaration under the inherent jurisdiction of the court.' }
      ccms_category_law { 'Family' }
      ccms_category_law_code { 'MAT' }
      ccms_matter { 'Domestic Abuse' }
      ccms_matter_code { 'MINJN' }
      default_service_level_id { create(:service_level, :with_real_data).id }
      default_cost_limitation_delegated_functions { 1350 }
      default_cost_limitation_substantive { 25_000 }
      involvement_type_applicant { true }
    end

    trait :as_occupation_order do
      code { 'PR0214' }
      ccms_code { 'DA005' }
      meaning { 'Occupation order' }
      name { 'occupation_order' }
      description { 'to be represented on an application for an occupation order.' }
      ccms_category_law { 'Family' }
      ccms_category_law_code { 'MAT' }
      ccms_matter { 'Domestic Abuse' }
      ccms_matter_code { 'MINJN' }
      default_service_level_id { create(:service_level, :with_real_data).id }
      default_cost_limitation_delegated_functions { 1350 }
      default_cost_limitation_substantive { 25_000 }
      involvement_type_applicant { true }
    end

    trait :with_scope_limitations do
      after(:create) do |proceeding_type|
        proceeding_type.scope_limitations << create(:scope_limitation, :substantive_default, joined_proceeding_type: proceeding_type)
        proceeding_type.scope_limitations << create(:scope_limitation, :delegated_functions_default, joined_proceeding_type: proceeding_type)
      end
    end
  end
end
