FactoryBot.define do
  factory :permission do
    sequence(:role) { |n| "role_#{n}" }
    sequence(:description) { |n| "The description for role_#{n}" }

    trait :passported do
      role { "application.passported.*" }
      description { "Can create, view, modify passported applications" }
    end

    trait :non_passported do
      role { "application.non_passported.*" }
      description { "Can create, view, modify non-passported applications" }
    end

    trait :employed do
      role { "application.non_passported.employment.*" }
      description { "Can submit applications for employed applicants " }
    end

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
