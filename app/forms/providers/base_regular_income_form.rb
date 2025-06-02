module Providers
  class BaseRegularIncomeForm < RegularTransactionForm
    INCOME_TYPES = %w[
      friends_or_family
      maintenance_in
      property_or_lodger
      pension
    ].freeze

    INCOME_TYPES.each do |income_type|
      attr_accessor :"#{income_type}_amount",
                    :"#{income_type}_frequency"
    end

    INCOME_TYPES.each do |attribute|
      # check_box_attribute = :"check_box_#{attribute}"
      amount_attribute = :"#{attribute}_amount"
      validates amount_attribute, currency: { greater_than_or_equal_to: 0 }, if: proc { |form| form.__send__(amount_attribute).present? }
    end


    def initialize(params = {})
      super(params)

      # binding.pry
      # pp regular_transactions
    end

  private

    def transaction_type_conditions
      { operation: "credit", parent_id: nil }
    end

    def transaction_type_exclusions
      { name: "benefits" }
    end

    def legal_aid_application_attributes
      { no_credit_transaction_types_selected: none_selected? }
    end
  end
end
