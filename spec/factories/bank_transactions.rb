FactoryBot.define do
  factory :bank_transaction do
    bank_account
    true_layer_id { SecureRandom.hex }
    description { Faker::Lorem.sentence }
    merchant { Faker::Lorem.sentence }
    happened_at { Faker::Date.between(from: 3.months.ago + 2.days, to: Time.current - 2.days) }
    currency { Faker::Currency.code }
    amount { rand(1...1_000_000.0).round(2) }
    running_balance { rand(1...1_000_000.0).round(2) }

    trait :debit do
      operation { :debit }
    end

    trait :credit do
      operation { :credit }
    end

    trait :benefits do
      operation { 'credit' }
      transaction_type { TransactionType.where(name: 'benefits').first || create(:transaction_type, :benefits) }
      meta_data { { code: 'CHB', label: 'child_benefit', name: 'Child Benefit', selected_by: 'System' } }
    end

    trait :uncategorised_credit_transaction do
      operation { 'credit' }
      transaction_type { nil }
    end

    trait :uncategorised_debit_transaction do
      operation { 'debit' }
      transaction_type { nil }
    end

    trait :disregarded_benefits do
      operation { 'credit' }
      transaction_type { TransactionType.where(name: 'excluded_benefits').first || create(:transaction_type, :benefits) }
      meta_data { { code: nil, label: 'grenfell_payments', name: 'Grenfell Tower fire victims payments', selected_by: 'System' } }
    end

    trait :unassigned_benefits do
      operation { 'credit' }
      transaction_type { TransactionType.where(name: 'benefits').first || create(:transaction_type, :benefits) }
    end

    trait :unknown_benefits do
      operation { 'credit' }
      transaction_type { TransactionType.where(name: 'benefits').first || create(:transaction_type, :benefits) }
      meta_data { { code: 'xxx', label: 'unknown', name: 'Unrecognised state benefit', selected_by: 'System' } }
    end

    trait :friends_or_family do
      operation { 'credit' }
      transaction_type { TransactionType.where(name: 'friends_or_family').first || create(:transaction_type, :friends_or_family) }
    end

    trait :maintenance_in do
      operation { 'credit' }
      transaction_type { TransactionType.where(name: 'maintenance_in').first || create(:transaction_type, :maintenance_in) }
    end

    trait :property_or_lodger do
      operation { 'credit' }
      transaction_type { TransactionType.where(name: 'property_or_lodger').first || create(:transaction_type, :property_or_lodger) }
    end

    trait :student_loan do
      operation { 'credit' }
      transaction_type { TransactionType.where(name: 'student_loan').first || create(:transaction_type, :student_loan) }
    end

    trait :pension do
      operation { 'credit' }
      transaction_type { TransactionType.where(name: 'pension').first || create(:transaction_type, :pension) }
    end

    trait :rent_or_mortgage do
      operation { 'debit' }
      transaction_type { TransactionType.where(name: 'rent_or_mortgage').first || create(:transaction_type, :rent_or_mortgage) }
    end

    trait :child_care do
      operation { 'debit' }
      transaction_type { TransactionType.where(name: 'child_care').first || create(:transaction_type, :child_care) }
    end

    trait :maintenance_out do
      operation { 'debit' }
      transaction_type { TransactionType.where(name: 'maintenance_out').first || create(:transaction_type, :maintenance_out) }
    end

    trait :legal_aid do
      operation { 'debit' }
      transaction_type { TransactionType.where(name: 'legal_aid').first || create(:transaction_type, :legal_aid) }
    end

    trait :with_meta do
      meta_data do
        { code: 'UC', label: 'universal_credit', name: 'Universal credit', selected_by: 'System' }
      end
    end

    trait :with_meta_tax do
      meta_data do
        { code: 'CTC', label: 'child_tax_credit', name: 'Child Tax credit', selected_by: 'System' }
      end
    end

    trait :flagged_multi_benefits do
      flags { { multi_benefit: true } }
    end
  end
end
