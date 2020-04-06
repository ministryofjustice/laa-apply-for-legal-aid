class TransactionType < ApplicationRecord
  default_scope { order(:sort_order) }

  # Note that names should be unique across the whole of NAMES - so both credit and debit
  NAMES = {
    credit: %i[
      benefits
      friends_or_family
      maintenance_in
      property_or_lodger
      student_loan
      pension
    ],
    debit: %i[
      rent_or_mortgage
      child_care
      maintenance_out
      legal_aid
    ]
  }.freeze

  OTHER_INCOME_TYPES = %w[
    friends_or_family
    maintenance_in
    property_or_lodger
    student_loan
    pension
  ].freeze

  scope :active, -> { where(archived_at: nil) }
  scope :debits, -> { active.where(operation: :debit) }
  scope :credits, -> { active.where(operation: :credit) }
  scope :income_for, ->(transaction_type_name) { active.where(operation: :credit, name: transaction_type_name) }
  scope :outgoing_for, ->(transaction_type_name) { active.where(operation: :debit, name: transaction_type_name) }

  def self.populate
    populate_records(true)
  end

  def self.populate_without_income
    populate_records(false)
  end

  def self.populate_records(include_other_income)
    NAMES.each_with_index do |(operation, names), op_index|
      names.each_with_index do |name, index|
        start_number = (op_index * 1000) + (index * 10)
        transaction_type = find_or_initialize_by(name: name, operation: operation)
        transaction_type.update! sort_order: start_number
      end
    end
    TransactionType.active.where.not(name: TransactionType::NAMES.values.flatten).update(archived_at: Time.now)
    return unless include_other_income

    TransactionType.where(name: OTHER_INCOME_TYPES).each do |tt|
      tt.update!(other_income: true)
    end
  end

  def self.for_income_type?(transaction_type_name)
    income_for(transaction_type_name).any?
  end

  def self.other_income
    TransactionType.where(other_income: true)
  end

  def label_name(journey: :citizens)
    I18n.t("transaction_types.names.#{journey}.#{name}")
  end

  def self.for_outgoing_type?(transaction_type_name)
    outgoing_for(transaction_type_name).any?
  end

  def citizens_label_name
    label_name(journey: :citizens)
  end

  def providers_label_name
    label_name(journey: :providers)
  end
end
