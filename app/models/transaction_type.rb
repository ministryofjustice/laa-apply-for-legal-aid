class TransactionType < ApplicationRecord
  default_scope { order(:sort_order) }

  # Note that names should be unique across the whole of NAMES - so both credit and debit
  NAMES = {
    credit: %i[
      benefits
      excluded_benefits
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

  EXCLUDED_BENEFITS = 'excluded_benefits'.freeze

  OTHER_INCOME_TYPES = %w[
    friends_or_family
    maintenance_in
    property_or_lodger
    student_loan
    pension
  ].freeze

  HIERARCHIES = {
    excluded_benefits: :benefits
  }.freeze

  scope :active, -> { where(archived_at: nil) }
  scope :debits, -> { active.where(operation: :debit) }
  scope :credits, -> { active.where(operation: :credit) }
  scope :income_for, ->(transaction_type_name) { active.where(operation: :credit, name: transaction_type_name) }
  scope :outgoing_for, ->(transaction_type_name) { active.where(operation: :debit, name: transaction_type_name) }
  scope :not_children, -> { where(parent_id: nil) }

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

  def self.find_with_children(*ids)
    all_ids = (ids + TransactionType.where(parent_id: ids).pluck(:id)).flatten
    where(id: all_ids)
  end

  def self.any_type_of(name)
    top_level_id = TransactionType.find_by(name: name)&.id
    return [] if top_level_id.nil?

    find_with_children(top_level_id)
  end

  def citizens_label_name
    label_name(journey: :citizens)
  end

  def providers_label_name
    label_name(journey: :providers)
  end

  def excluded_benefit?
    name == EXCLUDED_BENEFITS
  end

  def child?
    parent_id.present?
  end

  def parent?
    TransactionType.where(parent_id: id).any?
  end

  def parent
    TransactionType.find_by(id: parent_id)
  end

  def children
    TransactionType.where(parent_id: id)
  end

  def parent_or_self
    parent_id.present? ? parent : self
  end
end
