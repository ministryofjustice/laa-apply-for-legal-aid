module Providers
  module Means
    class IdentifyIncomeForm
      include ActiveModel::Model

      INCOME_TYPES = %i[benefits friends_or_family maintenance_in property_or_lodger pension].freeze

      attr_accessor :legal_aid_application_id, :params
      attr_reader :income_types

      INCOME_TYPES.each do |income_type|
        attr_accessor "#{income_type}_amount".to_sym, "#{income_type}_frequency".to_sym
      end

      validates :legal_aid_application_id, presence: true
      validates :income_types, presence: true, unless: :none_selected?
      validate :all_regular_payments_valid

      def initialize(params = {})
        @params = params
        @none_selected = none_selected.in?(params[:income_types] || [])
        super
      end

      def save
        return false unless valid?

        ApplicationRecord.transaction do
          legal_aid_application.update!(no_credit_transaction_types_selected: none_selected?)
          legal_aid_application.regular_payments.credits.destroy_all

          unless none_selected?
            regular_payments.each(&:save)
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

      def income_transaction_types
        TransactionType.income_for(INCOME_TYPES)
      end

      def none_selected
        "none"
      end

    private

      def none_selected?
        @none_selected
      end

      def legal_aid_application
        @legal_aid_application ||= LegalAidApplication.find(legal_aid_application_id)
      end

      def regular_payments
        @regular_payments ||= TransactionType.where(name: income_types).map do |transaction_type|
          regular_payment(transaction_type)
        end
      end

      def regular_payment(transaction_type)
        RegularPayment.new(
          legal_aid_application_id:,
          transaction_type:,
          amount: params.fetch("#{transaction_type.name}_amount", nil),
          frequency: params.fetch("#{transaction_type.name}_frequency", nil),
        )
      end

      def all_regular_payments_valid
        regular_payments.each do |regular_payment|
          next if regular_payment.valid?

          regular_payment.errors.each do |error|
            add_regular_payment_error_to_form(regular_payment.transaction_type.name, error)
          end
        end
      end

      def add_regular_payment_error_to_form(income_type, error)
        if error.attribute.in?(%i[amount frequency])
          errors.add("#{income_type}_#{error.attribute}".to_sym, error.type, **error.options)
        else
          errors.add(:base, error.type, **error.options)
        end
      end
    end
  end
end
