FactoryBot.define do
  factory :scope_limitation do
    proceeding

    trait :emergency do
      scope_type { 1 }
      code { "CV117" }
      meaning { "Interim order inc. return date" }
      description do
        'Limited to Family Help (Higher) and to all steps necessary to negotiate and conclude a settlement.
         To include the issue of proceedings and representation in those proceedings save in relation to or at a contested final hearing.'
      end
    end

    trait :substantive do
      scope_type { 0 }
      code { "FM062" }
      meaning { "Final hearing" }
      description { "Limited to all steps up to and including final hearing and any action necessary to implement (but not enforce) the order." }
    end
  end
end
