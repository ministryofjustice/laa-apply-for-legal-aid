class TransactionType < ApplicationRecord
  default_scope { order(:sort_order) }

  # Note that names should be unique across the whole of NAMES - so both credit and debit
  NAMES = {
    credit: %i[
      salary
      benefits
      maintenance_in
      property_or_lodger
      student_loan
      pension
      friends_or_family
    ],
    debit: %i[
      rent_or_mortgage
      child_care
      maintenance_out
      legal_aid
    ]
  }.freeze

  scope :active, -> { where(archived_at: nil) }
  scope :debits, -> { active.where(operation: :debit) }
  scope :credits, -> { active.where(operation: :credit) }

  def self.populate
    populate_records
  end

  def self.populate_records
    NAMES.each_with_index do |(operation, names), op_index|
      names.each_with_index do |name, index|
        start_number = (op_index * 1000) + (index * 10)
        transaction_type = find_or_initialize_by(name: name, operation: operation)
        transaction_type.update! sort_order: start_number
      end
    end

    TransactionType.active.where.not(name: TransactionType::NAMES.values.flatten).update(archived_at: Time.now)
  end

  def label_name
    I18n.t("transaction_types.names.#{name}")
  end
end
