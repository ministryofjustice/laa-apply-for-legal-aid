FactoryBot.define do
  factory :linked_application, class: "LinkedApplication" do
    lead_application { nil }
    associated_application { nil }

    trait :family do
      link_type_code { "FC_LEAD" }
    end
  end
end
