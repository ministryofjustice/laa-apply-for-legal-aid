FactoryBot.define do
  factory :proceeding_type do
    sequence(:code) { |n| format('PR%04d', n) }
    ccms_code { 'PBM23' }
    meaning { 'Meaning' }
    description { 'Description' }
    ccms_category_law { 'Category law' }
    ccms_category_law_code { 'Category law code' }
    ccms_matter { 'Matter' }
    ccms_matter_code { 'Matter code' }
    default_level_of_service_id { 3 }
    default_level_of_service_name { 'Default level of service' }
    default_cost_limitation_delegated_functions { 1 }
    default_cost_limitation_substantive { 2 }

    trait :with_real_data do
      code { 'PR0208' }
      ccms_code { 'DA001' }
      meaning { 'Inherent jurisdiction high court injunction' }
      description { 'to be represented on an application for an injunction, order or declaration under the inherent jurisdiction of the court.' }
      ccms_category_law { 'Family' }
      ccms_category_law_code { 'MAT' }
      ccms_matter { 'Domestic Abuse' }
      ccms_matter_code { 'MINJN' }
      default_level_of_service_id { 3 }
      default_level_of_service_name { 'Full Representation' }
      default_cost_limitation_delegated_functions { 1350 }
      default_cost_limitation_substantive { 5000 }
    end
  end
end
