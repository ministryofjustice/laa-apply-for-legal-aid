class AggregatedCashOutgoings < BaseAggregatedCashTransaction
  def self.cash_transaction_categories
    %i[
      rent_or_mortgage
      child_care
      maintenance_out
      legal_aid
    ].freeze
  end

  def self.operation
    :debits
  end

  attr_accessor :legal_aid_application_id,
                :none_selected

  attributes_for_transaction_types cash_transaction_categories

  def update(params)
    update_cash_attributes(params)
    return false unless valid?

    save_cash_transaction_records
  end

  private

  def model_error(type)
    I18n.t("activemodel.errors.models.#{self.class.to_s.underscore}.#{self.class.operation}.attributes.cash_outgoings.#{type}")
  end
end
