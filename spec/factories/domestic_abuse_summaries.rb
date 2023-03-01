FactoryBot.define do
  factory :domestic_abuse_summary, class: "ApplicationMeritsTask::DomesticAbuseSummary" do
    legal_aid_application
    warning_letter_sent { "false" }
    warning_letter_sent_details { Faker::Lorem.paragraph }
    police_notified { %w[true false].sample }
    police_notified_details { Faker::Lorem.paragraph }
    bail_conditions_set { "true" }
    bail_conditions_set_details { Faker::Lorem.paragraph }

    trait :police_notified_false do
      police_notified { false }
      police_notified_details { "details for non-notification of police" }
    end

    trait :police_notified_true do
      police_notified { true }
      police_notified_details { "details for police notification" }
    end
  end
end
