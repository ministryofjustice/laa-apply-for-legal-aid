module Providers
  module Means
    class RegularOutgoingsForm
      include ActiveModel::Model

      OUTGOING_TYPES = %w[
        rent_or_mortgage
        child_care
        maintenance_out
        legal_aid
      ].freeze

      attr_reader :transaction_type_ids, :legal_aid_application

      OUTGOING_TYPES.each do |outgoing_type|
        attr_accessor "#{outgoing_type}_amount".to_sym,
                      "#{outgoing_type}_frequency".to_sym
      end

      validates :transaction_type_ids, presence: true, unless: :none_selected?
      validate :all_regular_transactions_valid

      def initialize(params = {})
        @none_selected = none_selected.in?(params["transaction_type_ids"] || [])
        @legal_aid_application = params.delete(:legal_aid_application)
        @transaction_type_ids = params["transaction_type_ids"] ||
          @legal_aid_application.transaction_types.debits.not_children.pluck(:id)

        assign_regular_transaction_attributes

        super
      end

      def save
        return false unless valid?

        ApplicationRecord.transaction do
          destroy_transactions!

          build_legal_aid_application_transaction_types
          legal_aid_application.assign_attributes(
            no_debit_transaction_types_selected: none_selected?,
          )
          legal_aid_application.save!

          regular_transactions.each(&:save!)
        end

        true
      end

      def transaction_type_ids=(ids)
        @transaction_type_ids = if none_selected?
                                  []
                                else
                                  ids.compact_blank
                                end
      end

      def transaction_type_options
        TransactionType.not_children.debits
      end

      def none_selected
        "none"
      end

    private

      def assign_regular_transaction_attributes
        regular_transactions.each do |transaction|
          transaction_type = transaction.transaction_type
          public_send("#{transaction_type.name}_amount=", transaction.amount)
          public_send("#{transaction_type.name}_frequency=", transaction.frequency)
        end
      end

      def none_selected?
        @none_selected
      end

      def transaction_types
        transaction_type_options.where(id: transaction_type_ids)
      end

      def destroy_transactions!
        destroy_legal_aid_application_transaction_types!
        destroy_regular_outgoing_transactions!
        destroy_cash_outgoing_transactions!
      end

      def destroy_legal_aid_application_transaction_types!
        legal_aid_application
          .legal_aid_application_transaction_types
          .debits
          .where.not(transaction_type_id: transaction_type_ids)
          .destroy_all
      end

      def destroy_regular_outgoing_transactions!
        legal_aid_application
          .regular_outgoings
          .without(existing_outgoing_regular_transactions)
          .destroy_all
      end

      def destroy_cash_outgoing_transactions!
        legal_aid_application
          .cash_transactions
          .debits
          .where.not(transaction_type_id: transaction_type_ids)
          .destroy_all
      end

      def existing_outgoing_regular_transactions
        legal_aid_application
          .regular_outgoings
          .where(transaction_type_id: transaction_type_ids)
      end

      def build_legal_aid_application_transaction_types
        transaction_type_ids.each do |transaction_type_id|
          next if transaction_type_id.in?(legal_aid_application.transaction_type_ids)

          legal_aid_application.legal_aid_application_transaction_types.build(
            transaction_type_id:,
          )
        end
      end

      def regular_transactions
        @regular_transactions ||= transaction_types.map do |transaction_type|
          RegularTransaction.find_or_initialize_by(
            legal_aid_application:,
            transaction_type:,
          )
        end
      end

      def all_regular_transactions_valid
        regular_transactions.each do |transaction|
          transaction_type = transaction.transaction_type
          transaction.amount = public_send("#{transaction_type.name}_amount")
          transaction.frequency = public_send("#{transaction_type.name}_frequency")

          next if transaction.valid?

          transaction.errors.each do |error|
            add_regular_transaction_error_to_form(
              transaction.transaction_type.name,
              error,
            )
          end
        end
      end

      def add_regular_transaction_error_to_form(transaction_type, error)
        attribute = if error.attribute.in?(%i[amount frequency])
                      "#{transaction_type}_#{error.attribute}".to_sym
                    else
                      :base
                    end

        errors.add(attribute, error.type, **error.options)
      end
    end
  end
end
