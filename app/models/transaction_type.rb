class TransactionType < ApplicationRecord
  default_scope { order(:sort_order) }

  # Note that names should be unique across the whole of NAMES - so both credit and debit
  NAMES = {
    credit: %i[
      benefits
      excluded_benefits
      housing_benefit
      friends_or_family
      maintenance_in
      property_or_lodger
      pension
    ],
    debit: %i[
      rent_or_mortgage
      child_care
      maintenance_out
      legal_aid
    ],
  }.freeze

  DISREGARDED_BENEFITS = %w[
    excluded_benefits
    housing_benefit
  ].freeze

  OTHER_INCOME_TYPES = %w[
    friends_or_family
    maintenance_in
    property_or_lodger
    pension
  ].freeze

  HIERARCHIES = {
    excluded_benefits: :benefits,
    housing_benefit: :benefits,
  }.freeze

  scope :active, -> { where(archived_at: nil) }
  scope :debits, -> { active.where(operation: :debit) }
  scope :credits, -> { active.where(operation: :credit) }
  scope :income_for, ->(transaction_type_name) { active.where(operation: :credit, name: transaction_type_name) }
  scope :outgoing_for, ->(transaction_type_name) { active.where(operation: :debit, name: transaction_type_name) }
  scope :not_children, -> { where(parent_id: nil) }
  scope :without_disregarded_benefits, -> { not_children }
  scope :without_housing_benefits, -> { where.not(name: "housing_benefit") }
  scope :without_benefits, -> { where.not(name: "benefits") }

  def self.with_children(ids:)
    return none if ids.blank?

    where(id: ids).or(where(parent_id: ids))
  end

  def self.for_income_type?(transaction_type_name)
    income_for(transaction_type_name).any?
  end

  def self.for_outgoing_type?(transaction_type_name)
    outgoing_for(transaction_type_name).any?
  end

  def self.other_income
    where(other_income: true)
  end

  def label_name(journey: :providers)
    I18n.t("transaction_types.names.#{journey}.#{name}")
  end

  def providers_label_name
    label_name(journey: :providers)
  end

  def disregarded_benefit?
    name.in?(DISREGARDED_BENEFITS)
  end

  def child?
    parent_id.present?
  end

  def children
    self.class.where(parent_id: id)
  end

  def parent_or_self
    if parent_id.present?
      self.class.find(parent_id)
    else
      self
    end
  end
end
