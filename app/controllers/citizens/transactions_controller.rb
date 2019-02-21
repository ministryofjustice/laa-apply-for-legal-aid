module Citizens
  class TransactionsController < BaseController
    include Flowable
    before_action :authenticate_applicant!

    def show
      transaction_type
      bank_transactions
    end

    def update
      reset_selection
      set_selection

      go_forward
    end

    def date_from
      l(bank_transactions.last.happened_at.to_date, format: :long_date)
    end
    helper_method :date_from

    def date_to
      l(bank_transactions.first.happened_at.to_date, format: :long_date)
    end
    helper_method :date_to

    private

    def reset_selection
      bank_transactions.where(transaction_type_id: transaction_type.id).update_all(transaction_type_id: nil)
    end

    def set_selection
      BankTransaction
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
        BankTransaction
        .of_applicant(legal_aid_application.applicant)
        .where(operation: transaction_type.operation)
    end

    def legal_aid_application
      @legal_aid_application ||= LegalAidApplication.find(session[:current_application_ref])
    end
  end
end
