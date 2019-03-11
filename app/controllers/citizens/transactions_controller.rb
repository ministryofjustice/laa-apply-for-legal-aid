module Citizens
  class TransactionsController < BaseController
    include ApplicationFromSession
    before_action :authenticate_applicant!
    helper_method :date_from, :date_to

    def show
      transaction_type
      bank_transactions
    end

    def update
      reset_selection
      set_selection

      go_forward
    end

    private

    def date_from
      l(bank_transactions.last.happened_at.to_date, format: :long_date)
    end

    def date_to
      l(bank_transactions.first.happened_at.to_date, format: :long_date)
    end

    def reset_selection
      bank_transactions.where(transaction_type_id: transaction_type.id).update_all(transaction_type_id: nil)
    end

    def set_selection
      bank_transactions
        .where(id: transaction_ids_to_select)
        .update_all(transaction_type_id: transaction_type.id)
    end

    def transaction_ids_to_select
      bank_transactions.pluck(:id) & selected_transaction_ids
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
        .applicant
        .bank_transactions
        .where(operation: transaction_type.operation)
        .order(happened_at: :desc, description: :desc)
    end
  end
end
