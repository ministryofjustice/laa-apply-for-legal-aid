FactoryBot.define do
  factory :legal_aid_application, aliases: [:application] do
    provider

    trait :with_applicant do
      applicant
    end

    trait :with_applicant_and_address do
      applicant { create :applicant, :with_address }
    end

    trait :with_applicant_and_address_lookup do
      applicant { create :applicant, :with_address_lookup }
    end

    trait :provider_submitted do
      state { 'provider_submitted' }
    end

    trait :answers_checked do
      state { 'answers_checked' }
    end

    trait :checking_passported_answers do
      state { 'checking_passported_answers' }
    end

    trait :means_completed do
      state { 'means_completed' }
    end

    trait :checking_merits_answers do
      state { 'checking_merits_answers' }
    end

    trait :merits_completed do
      state { 'merits_completed' }
    end

    trait :checking_answers do
      state { :checking_answers }
    end

    trait :with_proceeding_types do
      transient do
        proceeding_types_count { 1 }
      end

      after(:create) do |application, evaluator|
        proceeding_types = if evaluator.proceeding_types.empty?
                             create_list(:proceeding_type, evaluator.proceeding_types_count)
                           else
                             evaluator.proceeding_types
                           end
        application.proceeding_types = proceeding_types
        application.save
      end
    end

    trait :with_proceeding_type_domestic_abuse do
      proceeding_types { [create(:proceeding_type, :domestic_abuse)] }
    end

    trait :with_own_home_mortgaged do
      own_home { 'mortgage' }
    end

    trait :with_own_home_owned_outright do
      own_home { 'owned_outright' }
    end

    trait :without_own_home do
      own_home { 'no' }
    end

    trait :with_home_sole_owner do
      shared_ownership { 'no_sole_owner' }
    end

    trait :with_home_shared_with_partner do
      shared_ownership { 'partner_or_ex_partner' }
    end

    trait :with_other_assets_declaration do
      other_assets_declaration { create :other_assets_declaration, :with_all_values }
    end

    trait :with_no_other_assets do
      other_assets_declaration { create :other_assets_declaration, :all_nil }
    end

    trait :with_savings_amount do
      savings_amount { create :savings_amount, :with_values }
    end

    trait :with_no_savings do
      savings_amount { create :savings_amount, :all_nil }
    end

    trait :with_no_other_assets do
      other_assets_declaration { create :other_assets_declaration, :all_nil }
    end

    trait :with_merits_assessment do
      merits_assessment { create :merits_assessment, :with_optional_text }
    end

    trait :with_merits_statement_of_case do
      statement_of_case { create :statement_of_case }
    end

    trait :with_respondent do
      respondent { create :respondent }
    end

    trait :with_everything do
      with_applicant
      provider_submitted
      with_savings_amount
      with_other_assets_declaration
      with_own_home_mortgaged
      property_value { Faker::Number.decimal.to_d }
      outstanding_mortgage_amount { Faker::Number.decimal.to_d }
      shared_ownership { LegalAidApplication::SHARED_OWNERSHIP_YES_REASONS.sample }
      percentage_home { Faker::Number.decimal(2).to_d }
      with_merits_assessment
      with_merits_statement_of_case
      with_respondent
    end

    trait :with_negative_benefit_check_result do
      benefit_check_result { build :benefit_check_result }
    end

    trait :with_positive_benefit_check_result do
      benefit_check_result { build :benefit_check_result, :positive }
    end

    trait :with_undetermined_benefit_check_result do
      benefit_check_result { build :benefit_check_result, :undetermined }
    end

    trait :draft do
      draft { true }
    end
  end
end
