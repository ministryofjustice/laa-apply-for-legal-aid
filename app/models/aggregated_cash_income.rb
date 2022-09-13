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
    update_cash_attributes(params)

    return false unless valid?

    save_cash_transaction_records
  end

  def cash_income_options
    if Setting.enhanced_bank_upload?
      legal_aid_application.regular_transactions.credits.map(&:transaction_type)
    else
      legal_aid_application.transaction_types.not_children.credits
    end
  end
end
