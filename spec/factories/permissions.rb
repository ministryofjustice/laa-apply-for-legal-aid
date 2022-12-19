FactoryBot.define do
  factory :permission do
    sequence(:role) { |n| "role_#{n}" }
    sequence(:description) { |n| "The description for role_#{n}" }

    trait :bank_statement_upload do
      role { "application.non_passported.bank_statement_upload.*" }
      description { "Can upload bank statements" }
    end

    trait :full_section_8 do
      role { "application.full_section_8.*" }
      description { "Can use full set of section 8 proceedings" }
    end
  end
end
