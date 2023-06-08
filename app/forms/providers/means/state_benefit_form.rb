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
      validates :frequency, inclusion: { in: ->(form) { form.frequency_options } }

      def frequency_options
        RegularTransaction.frequencies_for(state_benefit_transaction_type)
      end

    private

      def state_benefit_transaction_type
        TransactionType.find_by!(name: "benefits")
      end
    end
  end
end
