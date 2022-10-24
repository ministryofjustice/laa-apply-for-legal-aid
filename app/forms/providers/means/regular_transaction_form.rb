module Providers
  module Means
    class RegularTransactionForm
      include ActiveModel::Model

      attr_reader :transaction_type_ids, :legal_aid_application

      validates :transaction_type_ids, presence: true, unless: :none_selected?
      validate :all_regular_transactions_valid

      def initialize(params = {})
        @none_selected = none_selected.in?(params["transaction_type_ids"] || [])
        @legal_aid_application = params.delete(:legal_aid_application)
        @transaction_type_ids = params["transaction_type_ids"] || existing_transaction_type_ids

        assign_regular_transaction_attributes

        super
      end

      def save
        return false unless valid?

        ApplicationRecord.transaction do
          destroy_transactions!

          build_legal_aid_application_transaction_types
          legal_aid_application.assign_attributes(legal_aid_application_attributes)
          legal_aid_application.save!

          regular_transactions.each(&:save!)
        end

        true
      end

      def transaction_type_ids=(ids)
        @transaction_type_ids = if none_selected?
                                  []
                                else
                                  [ids].flatten.compact_blank
                                end
      end

      def transaction_type_options
        TransactionType.active.where(transaction_type_conditions)
      end

      def none_selected
        "none"
      end

    private

      def transaction_type_conditions
        raise(
          NotImplementedError,
          "#transaction_type_conditions must be implemented in the subclass",
        )
      end

      def legal_aid_application_attributes
        raise(
          NotImplementedError,
          "#legal_aid_application_attributes must be implemented in the subclass",
        )
      end

      def none_selected?
        @none_selected
      end

      def existing_transaction_type_ids
        legal_aid_application
          .transaction_types
          .where(transaction_type_conditions)
          .pluck(:id)
      end

      def assign_regular_transaction_attributes
        regular_transactions.each do |transaction|
          transaction_type = transaction.transaction_type
          public_send("#{transaction_type.name}_amount=", transaction.amount)
          public_send("#{transaction_type.name}_frequency=", transaction.frequency)
        end
      end

      def build_legal_aid_application_transaction_types
        transaction_type_ids.each do |transaction_type_id|
          next if transaction_type_id.in?(legal_aid_application.transaction_type_ids)

          legal_aid_application.legal_aid_application_transaction_types.build(
            transaction_type_id:,
          )
        end
      end

      def destroy_transactions!
        dependent_transaction_models.each do |model|
          legal_aid_application
            .public_send(model)
            .includes(:transaction_type)
            .where(transaction_type: transaction_type_conditions)
            .where.not(transaction_type_id: transaction_type_ids)
            .destroy_all
        end
      end

      def dependent_transaction_models
        %i[
          legal_aid_application_transaction_types
          regular_transactions
          cash_transactions
        ]
      end

      def regular_transactions
        @regular_transactions ||= transaction_types.map do |transaction_type|
          RegularTransaction.find_or_initialize_by(
            legal_aid_application:,
            transaction_type:,
          )
        end
      end

      def transaction_types
        transaction_type_options.where(id: transaction_type_ids)
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
