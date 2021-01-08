class AggregatedCashIncome < BaseAggregatedCashTransaction
  def self.cash_transaction_categories
    %i[
      benefits
      friends_or_family
      maintenance_in
      property_or_lodger
      pension
    ].freeze
  end

  def self.operation
    :credits
  end

  attr_accessor :legal_aid_application_id,
                :none_selected

  attributes_for_transaction_types cash_transaction_categories

  def update(params)
    update_attributes(params)

    return false unless valid?

    save_cash_transaction_records
  end

  private

  def model_error(type)
    I18n.t("activemodel.errors.models.aggregated_cash_income.#{self.class.operation}.attributes.none_selected.#{type}")
  end

  def amount_error(type)
    I18n.t("errors.cash_amount.#{type}")
  end
end
