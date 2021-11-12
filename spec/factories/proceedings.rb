FactoryBot.define do
  factory :proceeding do
    legal_aid_application

    sequence(:proceeding_case_id) { |n| n + 55_000_000 }

    trait :da001 do
      lead_proceeding { true }
      ccms_code { 'DA001' }
      meaning { 'Inherent jurisdiction high court injunction' }
      description { 'to be represented on an application for an injunction, order or declaration under the inherent jurisdiction of the court.' }
      substantive_cost_limitation { 25_000 }
      delegated_functions_cost_limitation { rand(1...1_000_000.0).round(2) }
      substantive_scope_limitation_code { 'FM062' }
      substantive_scope_limitation_meaning { 'Final hearing' }
      substantive_scope_limitation_description { 'Limited to all steps up to and including final hearing and any action necessary to implement (but not enforce) the order.' }
      delegated_functions_scope_limitation_code { 'CV117' }
      delegated_functions_scope_limitation_meaning { 'Interim order inc. return date' }
      delegated_functions_scope_limitation_description do
        'Limited to Family Help (Higher) and to all steps necessary to negotiate and conclude a settlement.
         To include the issue of proceedings and representation in those proceedings save in relation to or at a contested final hearing.'
      end
      used_delegated_functions_on { nil }
      used_delegated_functions_reported_on { nil }
      name { 'inherent_jurisdiction_high_court_injunction' }
      matter_type { 'Domestic Abuse' }
      category_of_law { 'Family' }
      category_law_code { 'MAT' }
      ccms_matter_code { 'MINJN' }
    end

    trait :da004 do
      lead_proceeding { false }
      ccms_code { 'DA004' }
      meaning { 'Non-molestation order' }
      description { 'to be represented on an application for a non-molestation order.' }
      substantive_cost_limitation { 25_000 }
      delegated_functions_cost_limitation { rand(1...1_000_000.0).round(2) }
      substantive_scope_limitation_code { 'AA019' }
      substantive_scope_limitation_meaning { 'Injunction FLA-to final hearing' }
      substantive_scope_limitation_description { 'Limited to all steps up to and including final hearing and any action necessary to implement (but not enforce) the order.' }
      delegated_functions_scope_limitation_code { 'CV117' }
      delegated_functions_scope_limitation_meaning { 'Interim order inc. return date' }
      delegated_functions_scope_limitation_description do
        'As to proceedings under Part IV Family Law Act 1996 limited to all steps up to and including obtaining and serving a
         final order and in the event of breach leading to the exercise of a power of arrest to representation on the consideration
         of the breach by the court (but excluding applying for a warrant of arrest, if not attached, and representation in contempt proceedings).'
      end
      used_delegated_functions_on { Faker::Date.between(from: 10.days.ago, to: Time.current - 2.days) }
      used_delegated_functions_reported_on { Time.zone.today }
      name { 'nonmolestation_order' }
      matter_type { 'Domestic Abuse' }
      category_of_law { 'Family' }
      category_law_code { 'MAT' }
      ccms_matter_code { 'MINJN' }
    end

    trait :se013 do
      lead_proceeding { false }
      ccms_code { 'SE013' }
      meaning { 'Child arrangements order (contact)' }
      description { 'to be represented on an application for a child arrangements order –where the child(ren) will live' }
      substantive_cost_limitation { 25_000 }
      delegated_functions_cost_limitation { rand(1...1_000_000.0).round(2) }
      substantive_scope_limitation_code { 'FM059' }
      substantive_scope_limitation_meaning { 'FHH Children' }
      substantive_scope_limitation_description do
        'Limited to Family Help (Higher) and to all steps necessary to negotiate and conclude a settlement.
        To include the issue of proceedings and representation in those proceedings save in relation to or at a contested final hearing.'
      end
      delegated_functions_scope_limitation_code { 'CV117' }
      delegated_functions_scope_limitation_meaning { 'Interim order inc. return date' }
      delegated_functions_scope_limitation_description do
        'Limited to Family Help (Higher) and to all steps necessary to negotiate and conclude a settlement.
        To include the issue of proceedings and representation in those proceedings save in relation to or at a contested final hearing.'
      end
      used_delegated_functions_on { nil }
      used_delegated_functions_reported_on { nil }
      name { 'child_arrangements_order_contact' }
      matter_type { 'Section 8 orders' }
      category_of_law { 'Family' }
      category_law_code { 'MAT' }
      ccms_matter_code { 'KSEC8' }
    end

    trait :se014 do
      lead_proceeding { false }
      ccms_code { 'SE014' }
      meaning { 'Child arrangements order (residence)' }
      description { 'to be represented on an application for a child arrangements order –where the child(ren) will live' }
      substantive_cost_limitation { 25_000 }
      delegated_functions_cost_limitation { rand(1...1_000_000.0).round(2) }
      substantive_scope_limitation_code { 'FM059' }
      substantive_scope_limitation_meaning { 'FHH Children' }
      substantive_scope_limitation_description do
        'Limited to Family Help (Higher) and to all steps necessary to negotiate and conclude a settlement.
        To include the issue of proceedings and representation in those proceedings save in relation to or at a contested final hearing.'
      end
      delegated_functions_scope_limitation_code { 'CV117' }
      delegated_functions_scope_limitation_meaning { 'Interim order inc. return date' }
      delegated_functions_scope_limitation_description do
        'Limited to Family Help (Higher) and to all steps necessary to negotiate and conclude a settlement.
        To include the issue of proceedings and representation in those proceedings save in relation to or at a contested final hearing.'
      end
      used_delegated_functions_on { nil }
      used_delegated_functions_reported_on { nil }
      name { 'child_arrangements_order_residence' }
      matter_type { 'Section 8 orders' }
      category_of_law { 'Family' }
      category_law_code { 'MAT' }
      ccms_matter_code { 'KSEC8' }
    end
  end
end
