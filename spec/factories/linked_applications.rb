FactoryBot.define do
  factory :linked_application, class: "LinkedApplication" do
    lead_application { lead_application }
    associated_application { associated_application }
    link_type_code { "FC_LEAD" }

    trait :family do
      link_type_code { "FC_LEAD" }
    end
  end
end
