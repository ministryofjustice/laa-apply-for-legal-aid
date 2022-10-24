module Providers
  module Means
    class RegularIncomeForm < RegularTransactionForm
      INCOME_TYPES = %w[
        benefits
        friends_or_family
        maintenance_in
        property_or_lodger
        student_loan
        pension
      ].freeze

      DISREGARDED_BENEFIT_CATEGORIES = %w[
        carer_and_disability
        low_income
        other
      ].freeze

      INCOME_TYPES.each do |income_type|
        attr_accessor "#{income_type}_amount".to_sym,
                      "#{income_type}_frequency".to_sym
      end

      def disregarded_benefit_categories
        DISREGARDED_BENEFIT_CATEGORIES
      end

    private

      def transaction_type_conditions
        { operation: "credit", parent_id: nil }
      end

      def legal_aid_application_attributes
        { no_credit_transaction_types_selected: none_selected? }
      end
    end
  end
end
