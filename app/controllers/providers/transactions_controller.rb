module Providers
  class TransactionsController < ProviderBaseController
    def show
      transaction_type
      bank_transactions
    end

    def update
      reset_selection
      set_selection
      continue_or_draft
    end

    private

    def reset_selection
      bank_transactions.where(transaction_type_id: transaction_type.id).update_all(transaction_type_id: nil)
    end

    def set_selection
      new_values = { transaction_type_id: transaction_type.id }
      new_values[:meta_data] = 'manually_chosen' if transaction_type.name.eql?('benefits')
      bank_transactions
        .where(id: selected_transaction_ids)
        .update_all(new_values)
    end

    def selected_transaction_ids
      params[:transaction_ids].select(&:present?)
    end

    def transaction_type
      @transaction_type ||= TransactionType.find_by(name: params[:transaction_type]) || TransactionType.first
    end

    def bank_transactions
      @bank_transactions ||=
        legal_aid_application
        .bank_transactions
        .where(operation: transaction_type.operation)
        .order(happened_at: :desc, description: :desc)
    end
  end
end
