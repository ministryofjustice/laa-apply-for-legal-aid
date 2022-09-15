module Providers
  module Means
    class RegularOutgoingsForm
      include ActiveModel::Model

      OUTGOING_TYPES = %i[rent_or_mortgage child_care maintenance_out legal_aid].freeze

      attr_accessor :legal_aid_application_id, :params
      attr_reader :outgoing_types

      OUTGOING_TYPES.each do |outgoing_type|
        attr_accessor "#{outgoing_type}_amount".to_sym, "#{outgoing_type}_frequency".to_sym
      end

      validates :legal_aid_application_id, presence: true
      validates :outgoing_types, presence: true, unless: :none_selected?
      validate :all_regular_payments_valid

      def initialize(params = {})
        @params = params
        @none_selected = none_selected.in?(params[:outgoing_types] || [])
        super
      end

      def save
        return false unless valid?

        ApplicationRecord.transaction do
          legal_aid_application.update!(no_debit_transaction_types_selected: none_selected?)
          legal_aid_application.regular_payments.debits.destroy_all

          unless none_selected?
            regular_payments.each(&:save)
          end
        end

        true
      end

      def outgoing_types=(names)
        @outgoing_types = none_selected? ? [] : names.compact_blank
      end

      def outgoing_transaction_types
        TransactionType.outgoing_for(OUTGOING_TYPES)
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
        @regular_payments ||= TransactionType.where(name: outgoing_types).map do |transaction_type|
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

      def add_regular_payment_error_to_form(outgoing_type, error)
        if error.attribute.in?(%i[amount frequency])
          errors.add("#{outgoing_type}_#{error.attribute}".to_sym, error.type, **error.options)
        else
          errors.add(:base, error.type, **error.options)
        end
      end
    end
  end
end
