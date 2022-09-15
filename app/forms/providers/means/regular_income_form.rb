module Providers
  module Means
    class RegularIncomeForm
      include ActiveModel::Model

      INCOME_TYPES = %w[benefits friends_or_family maintenance_in property_or_lodger pension].freeze

      attr_accessor :legal_aid_application, :params
      attr_reader :income_types

      INCOME_TYPES.each do |income_type|
        attr_accessor "#{income_type}_amount".to_sym, "#{income_type}_frequency".to_sym
      end

      validates :income_types, presence: true, unless: :none_selected?
      validate :all_regular_transactions_valid

      def initialize(params = {})
        @params = params
        @none_selected = none_selected.in?(params["income_types"] || [])
        super
      end

      def save
        return false unless valid?

        ApplicationRecord.transaction do
          legal_aid_application.update!(no_credit_transaction_types_selected: none_selected?)
          legal_aid_application.regular_transactions.credits.destroy_all
          legal_aid_application.cash_transactions.credits.destroy_all

          unless none_selected?
            regular_transactions.each(&:save)
          end
        end

        true
      end

      def income_types=(names)
        @income_types = if none_selected?
                          []
                        else
                          names.compact_blank
                        end
      end

      def none_selected
        "none"
      end

    private

      def none_selected?
        @none_selected
      end

      def regular_transactions
        @regular_transactions ||= TransactionType.where(name: income_types).map do |transaction_type|
          regular_transaction(transaction_type)
        end
      end

      def regular_transaction(transaction_type)
        RegularTransaction.new(
          legal_aid_application:,
          transaction_type:,
          amount: params.fetch("#{transaction_type.name}_amount", nil),
          frequency: params.fetch("#{transaction_type.name}_frequency", nil),
        )
      end

      def all_regular_transactions_valid
        regular_transactions.each do |regular_transaction|
          next if regular_transaction.valid?

          regular_transaction.errors.each do |error|
            add_regular_transaction_error_to_form(regular_transaction.transaction_type.name, error)
          end
        end
      end

      def add_regular_transaction_error_to_form(income_type, error)
        if error.attribute.in?(%i[amount frequency])
          errors.add("#{income_type}_#{error.attribute}".to_sym, error.type, **error.options)
        else
          errors.add(:base, error.type, **error.options)
        end
      end
    end
  end
end
