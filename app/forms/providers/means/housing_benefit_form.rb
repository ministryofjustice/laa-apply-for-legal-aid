module Providers
  module Means
    class HousingBenefitForm < RegularTransactionForm
      include ApplicantOwner

      attr_accessor :housing_benefit_amount, :housing_benefit_frequency

      delegate :applicant_in_receipt_of_housing_benefit, to: :legal_aid_application

      def housing_benefit_transaction_type
        TransactionType.find_by(name: "housing_benefit")
      end

      def frequency_options
        RegularTransaction.frequencies_for(housing_benefit_transaction_type)
      end

      def housing_benefit_selected?
        transaction_type_ids.include?(housing_benefit_transaction_type.id)
      end

    private

      def transaction_type_conditions
        { name: "housing_benefit" }
      end

      def transaction_type_exclusions
        {}
      end

      def legal_aid_application_attributes
        { applicant_in_receipt_of_housing_benefit: housing_benefit_selected? }
      end
    end
  end
end
