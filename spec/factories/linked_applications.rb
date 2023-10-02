FactoryBot.define do
  factory :linked_application, class: "LinkedApplication" do
    lead_application { lead_application }
    associated_application { associated_application }
    link_type_code { "FAMILY" }
    link_type_description { "Family" }
  end
end
