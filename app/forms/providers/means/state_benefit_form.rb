module Providers
  module Means
    class StateBenefitForm < BaseForm
      form_for RegularTransaction

      attr_accessor :description,
                    :amount,
                    :frequency,
                    :transaction_type_id

      attr_reader :owner_id, :owner_type

      validates :description, presence: true
      validates :amount, currency: { greater_than: 0 }

      validate :frequency_inclusion

      def frequency_options
        RegularTransaction.frequencies_for(state_benefit_transaction_type)
      end

      def attributes_to_clean
        %i[amount]
      end

    private

      def state_benefit_transaction_type
        TransactionType.find_by!(name: "benefits")
      end

      def frequency_inclusion
        return if frequency_options.include?(frequency)

        errors.add(:frequency, frequency_error_text)
      end

      def frequency_error_text
        error_text = model.owner_type.eql?("Applicant") ? "your client" : "the partner"
        I18n.t("activemodel.errors.models.regular_transaction.attributes.frequency.inclusion", party: error_text)
      end
    end
  end
end
