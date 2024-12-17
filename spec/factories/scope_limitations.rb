FactoryBot.define do
  factory :scope_limitation do
    proceeding factory: %i[proceeding da001]

    trait :emergency do
      scope_type { 1 }
      code { "CV117" }
      meaning { "Interim order inc. return date" }
      description do
        'Limited to Family Help (Higher) and to all steps necessary to negotiate and conclude a settlement.
         To include the issue of proceedings and representation in those proceedings save in relation to or at a contested final hearing.'
      end
    end

    trait :emergency_cv118 do
      scope_type { 1 }
      code { "CV118" }
      meaning { "Hearing" }
      description { "Limited to all steps up to and including the hearing on [see additional limitation notes]" }
    end

    trait :substantive do
      scope_type { 0 }
      code { "FM062" }
      meaning { "Final hearing" }
      description { "Limited to all steps up to and including final hearing and any action necessary to implement (but not enforce) the order." }
    end

    trait :substantive_CV119 do
      scope_type { 0 }
      code { "CV119" }
      meaning { "General Report" }
      description { "Limited to obtaining a report from [see additional limitation notes]" }
    end

    trait :substantive_cv027 do
      scope_type { 0 }
      code { "CV027" }
      meaning { "Hearing/Adjournment" }
      description { "Limited to all steps (including any adjournment thereof) up to and including the hearing on" }
    end
  end
end
