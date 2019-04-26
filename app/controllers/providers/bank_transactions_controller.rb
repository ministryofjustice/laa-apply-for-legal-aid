module Providers
  class BankTransactionsController < ProviderBaseController
    before_action :authorize_legal_aid_application

    def remove_transaction_type
      bank_transaction.update!(transaction_type: nil)
      head :ok
    end

    private

    def bank_transaction
      @bank_transaction ||= @legal_aid_application.bank_transactions.find(params[:id])
    end

    def authorize_legal_aid_application
      authorize @legal_aid_application
    end
  end
end
