FactoryBot.define do
  factory :application_proceeding_type do
    proceeding_type
    legal_aid_application

    trait :with_chances_of_success do
      after(:create) do |application_proceeding_type|
        create :chances_of_success, application_proceeding_type: application_proceeding_type
      end
    end

    trait :with_proceeding_type_scope_limitations do
      after(:create) do |application_proceeding_type|
        apt = application_proceeding_type
        pt = apt.proceeding_type
        default_subst_sl = pt.default_substantive_scope_limitation || create(:scope_limitation, :substantive, joined_proceeding_type: pt)
        default_df_sl = pt.default_delegated_functions_scope_limitation || create(:scope_limitation, :delegated_functions, joined_proceeding_type: pt)
        apt.application_proceeding_types_scope_limitations << AssignedSubstantiveScopeLimitation.new(scope_limitation: default_subst_sl)
        apt.application_proceeding_types_scope_limitations << AssignedDfScopeLimitation.new(scope_limitation: default_df_sl)
      end
    end

    trait :with_substantive_scope_limitation do
      after(:create) do |application_proceeding_type|
        pt = application_proceeding_type.proceeding_type
        sl = create :scope_limitation, :substantive_default, joined_proceeding_type: pt
        AssignedSubstantiveScopeLimitation.create!(application_proceeding_type_id: application_proceeding_type.id,
                                                   scope_limitation_id: sl.id)
      end
    end

    trait :with_delegated_functions_scope_limitation do
      after(:create) do |application_proceeding_type|
        pt = application_proceeding_type.proceeding_type
        sl = create :scope_limitation, :delegated_functions_default, joined_proceeding_type: pt
        apt = application.application_proceeding_types.find_by(proceeding_type_id: pt.id)
        AssignedDfScopeLimitation.create!(application_proceeding_type_id: apt.id,
                                          scope_limitation_id: sl.id)
      end
    end
  end
end
