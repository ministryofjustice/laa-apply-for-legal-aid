module Providers
  module Means
    class RegularOutgoingsForm < RegularTransactionForm
      include ApplicantOwner
      OUTGOING_TYPES = %w[
        rent_or_mortgage
        child_care
        maintenance_out
        legal_aid
      ].freeze

      OUTGOING_TYPES.each do |outgoing_type|
        attr_accessor "#{outgoing_type}_amount".to_sym,
                      "#{outgoing_type}_frequency".to_sym
      end

    private

      delegate :applicant_in_receipt_of_housing_benefit, to: :legal_aid_application

      def transaction_type_conditions
        { operation: "debit", parent_id: nil }
      end

      def transaction_type_exclusions
        {}
      end

      def legal_aid_application_attributes
        {
          no_debit_transaction_types_selected: none_selected?,
          applicant_in_receipt_of_housing_benefit: (
            applicant_in_receipt_of_housing_benefit if housing_payments_selected?
          ),
        }
      end

      def destroy_transactions!
        super

        unless housing_payments_selected?
          destroy_housing_benefit_transactions!
        end
      end

      def housing_payments_selected?
        transaction_types.exists?(name: "rent_or_mortgage")
      end

      def destroy_housing_benefit_transactions!
        dependent_transaction_models.each do |model|
          legal_aid_application
            .public_send(model)
            .includes(:transaction_type)
            .where(transaction_type: { name: "housing_benefit" })
            .destroy_all
        end
      end
    end
  end
end
