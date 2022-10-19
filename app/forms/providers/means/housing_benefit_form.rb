module Providers
  module Means
    class HousingBenefitForm
      include ActiveModel::Model

      attr_accessor :housing_benefit,
                    :housing_benefit_amount,
                    :housing_benefit_frequency

      attr_reader :legal_aid_application

      validates :housing_benefit, inclusion: { in: %w[true false] }

      validates :housing_benefit_amount,
                currency: { greater_than: 0 },
                if: :applicant_in_receipt_of_housing_benefit?

      validates :housing_benefit_frequency,
                inclusion: { in: ->(form) { form.frequency_options } },
                if: :applicant_in_receipt_of_housing_benefit?

      def initialize(params = {})
        @legal_aid_application = params.delete(:legal_aid_application)

        if params[:housing_benefit].nil?
          assign_housing_benefit_attributes
        end

        super
      end

      def save
        return false unless valid?

        ApplicationRecord.transaction do
          legal_aid_application.applicant_in_receipt_of_housing_benefit = housing_benefit

          if applicant_in_receipt_of_housing_benefit?
            build_housing_benefit_transaction_type
            build_housing_benefit_regular_transaction
          else
            destroy_housing_benefit_transaction_type!
            destroy_housing_benefit_regular_transaction!
          end

          legal_aid_application.save!
        end

        true
      end

      def frequency_options
        RegularTransaction.frequencies_for(housing_benefit_transaction_type)
      end

    private

      def applicant_in_receipt_of_housing_benefit?
        housing_benefit == "true"
      end

      def assign_housing_benefit_attributes
        @housing_benefit = @legal_aid_application.applicant_in_receipt_of_housing_benefit
        @housing_benefit_amount = housing_benefit_regular_transaction&.amount
        @housing_benefit_frequency = housing_benefit_regular_transaction&.frequency
      end

      def build_housing_benefit_transaction_type
        legal_aid_application
          .legal_aid_application_transaction_types
          .find_or_initialize_by(
            transaction_type: housing_benefit_transaction_type,
          )
      end

      def build_housing_benefit_regular_transaction
        housing_benefit_transaction = legal_aid_application
          .regular_transactions
          .find_or_initialize_by(
            transaction_type: housing_benefit_transaction_type,
          )
        housing_benefit_transaction.assign_attributes(
          amount: housing_benefit_amount,
          frequency: housing_benefit_frequency,
        )
        housing_benefit_transaction.save!
      end

      def destroy_housing_benefit_transaction_type!
        legal_aid_application
          .legal_aid_application_transaction_types
          .includes(:transaction_type)
          .where(transaction_type: { name: "housing_benefit" })
          .destroy_all
      end

      def destroy_housing_benefit_regular_transaction!
        legal_aid_application
          .regular_transactions
          .includes(:transaction_type)
          .where(transaction_type: { name: "housing_benefit" })
          .destroy_all
      end

      def housing_benefit_regular_transaction
        legal_aid_application
          .regular_transactions
          .includes(:transaction_type)
          .find_by(transaction_type: { name: "housing_benefit" })
      end

      def housing_benefit_transaction_type
        TransactionType.find_by!(name: "housing_benefit")
      end
    end
  end
end
