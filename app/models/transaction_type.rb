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
      council_tax
      child_care
      maintenance_out
      legal_aid
    ]
  }.freeze

  TRANSACTION_TYPES_WITH_HINT_TEXT = %i[benefits].freeze

  scope :debits, -> { where(operation: :debit) }
  scope :credits, -> { where(operation: :credit) }

  def self.populate
    populate_records
    populate_sort_order(:credit, 1000)
    populate_sort_order(:debit, 2000)
  end

  def self.populate_records
    existing = pluck(:name).map(&:to_sym)
    NAMES.each do |operation, names|
      (names - existing).each { |name| create!(name: name, operation: operation) }
    end
  end

  def self.populate_sort_order(operation, start_number)
    NAMES[operation].each_with_index do |name, index|
      tt = TransactionType.find_by(name: name)
      tt.update(sort_order: start_number + (index * 100))
    end
  end

  private_class_method :populate_records, :populate_sort_order

  def label_name
    I18n.t("transaction_types.names.#{name}")
  end
end
