FactoryBot.define do
  factory :linked_application, class: "LinkedApplication" do
    lead_application { lead_application }
    associated_application { associated_application }
    link_type_code { "FAMILY" }

    trait :family do
      link_type_code { "FAMILY" }
    end
  end
end
