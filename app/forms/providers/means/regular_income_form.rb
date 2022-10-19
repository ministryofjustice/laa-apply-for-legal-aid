module Providers
  module Means
    class RegularIncomeForm
      include ActiveModel::Model

      INCOME_TYPES = %w[
        benefits
        friends_or_family
        maintenance_in
        property_or_lodger
        student_loan
        pension
      ].freeze

      DISREGARDED_BENEFIT_CATEGORIES = %w[
        carer_and_disability
        low_income
        other
      ].freeze

      attr_reader :transaction_type_ids, :legal_aid_application

      INCOME_TYPES.each do |income_type|
        attr_accessor "#{income_type}_amount".to_sym,
                      "#{income_type}_frequency".to_sym
      end

      validates :transaction_type_ids, presence: true, unless: :none_selected?
      validate :all_regular_transactions_valid

      def initialize(params = {})
        @none_selected = none_selected.in?(params["transaction_type_ids"] || [])
        @legal_aid_application = params.delete(:legal_aid_application)
        @transaction_type_ids = params["transaction_type_ids"] ||
          @legal_aid_application.transaction_types.credits.not_children.pluck(:id)

        assign_regular_transaction_attributes

        super
      end

      def save
        return false unless valid?

        ApplicationRecord.transaction do
          destroy_transactions!

          build_legal_aid_application_transaction_types
          legal_aid_application.assign_attributes(
            no_credit_transaction_types_selected: none_selected?,
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
        TransactionType.not_children.credits
      end

      def disregarded_benefit_categories
        DISREGARDED_BENEFIT_CATEGORIES
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
        destroy_regular_income_transactions!
        destroy_cash_income_transactions!
      end

      def destroy_legal_aid_application_transaction_types!
        legal_aid_application
          .legal_aid_application_transaction_types
          .credits
          .where.not(transaction_type_id: transaction_type_ids_to_keep)
          .destroy_all
      end

      def destroy_regular_income_transactions!
        legal_aid_application
          .regular_incomes
          .where.not(transaction_type_id: transaction_type_ids_to_keep)
          .destroy_all
      end

      def destroy_cash_income_transactions!
        legal_aid_application
          .cash_transactions
          .credits
          .where.not(transaction_type_id: transaction_type_ids_to_keep)
          .destroy_all
      end

      def transaction_type_ids_to_keep
        @transaction_type_ids_to_keep ||= transaction_type_ids + [housing_benefit_id]
      end

      def housing_benefit_id
        @housing_benefit_id ||= TransactionType.find_by!(name: "housing_benefit").id
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
