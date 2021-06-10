FactoryBot.define do
  factory :proceeding_type do
    association :default_level_of_service, factory: %i[service_level with_real_data]

    sequence(:code) { |n| format('PR%<number>04d', number: n) }
    sequence(:ccms_code) { |n| format('DA%<number>03d', number: n) }
    meaning { "Meaning-#{ccms_code}" }
    name { "name_#{ccms_code.downcase}" }
    description { "Description-#{ccms_code}" }
    ccms_category_law { 'Category law' }
    ccms_category_law_code { 'Category law code' }
    ccms_matter { 'Domestic Abuse' }
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

    trait :as_prohibited_steps_order do
      code { 'PH001' }
      ccms_code { 'SE003' }
      meaning { 'Prohibited Steps Order-S8' }
      name { 'prohibited_steps_order_s8' }
      description { 'to be represented on an application for a prohibited steps order.' }
      ccms_category_law { 'Family' }
      ccms_category_law_code { 'MAT' }
      ccms_matter { 'Section 8 orders' }
      ccms_matter_code { 'KSEC8' }
      default_service_level_id { create(:service_level, :with_real_data).id }
      default_cost_limitation_delegated_functions { 1350 }
      default_cost_limitation_substantive { 25_000 }
      involvement_type_applicant { true }
    end

    trait :as_section_8_child_residence do
      code { 'PH0004' }
      ccms_code { 'SE014' }
      meaning { 'Child arrangements order (residence)' }
      name { 'child_arrangements_order_residence' }
      description { 'to be represented on an application for a child arrangements order –where the child(ren) will live' }
      ccms_category_law { 'Family' }
      ccms_category_law_code { 'MAT' }
      ccms_matter { 'Section 8 orders' }
      ccms_matter_code { 'KSEC8' }
      default_service_level_id { create(:service_level, service_level_number: 1).id }
      default_cost_limitation_delegated_functions { 1350 }
      default_cost_limitation_substantive { 25_000 }
      involvement_type_applicant { true }
    end

    trait :with_scope_limitations do
      after(:create) do |proceeding_type|
        create(:scope_limitation, :substantive_default, joined_proceeding_type: proceeding_type)
        create(:scope_limitation, :delegated_functions_default, joined_proceeding_type: proceeding_type)
      end
    end

    trait :domestic_abuse do
      sequence(:ccms_code) { |n| format('DA%<number>03d', number: n) }
      ccms_matter { 'Domestic Abuse' }
    end

    trait :section8 do
      sequence(:ccms_code) { |n| format('SE%<number>03d', number: n) }
      ccms_matter { 'Section 8 orders' }
    end

    trait :da001 do
      ccms_code { 'DA001' }
      ccms_matter { 'Domestic Abuse' }
    end

    trait :da004 do
      ccms_code { 'DA004' }
      ccms_matter { 'Domestic Abuse' }
    end

    trait :se013 do
      ccms_code { 'SE013' }
      ccms_matter { 'Section 8 orders' }
    end

    trait :se014 do
      ccms_code { 'SE014' }
      ccms_matter { 'Section 8 orders' }
    end
  end
end
