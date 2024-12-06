module Providers
  class BaseRegularIncomeForm < RegularTransactionForm
    INCOME_TYPES = %w[
      benefits
      friends_or_family
      maintenance_in
      property_or_lodger
      pension
    ].freeze

    INCOME_TYPES.each do |income_type|
      attr_accessor :"#{income_type}_amount",
                    :"#{income_type}_frequency"
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
