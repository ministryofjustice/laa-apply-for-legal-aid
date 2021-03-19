module Providers
  class BankTransactionsController < ProviderBaseController
    def remove_transaction_type
      bank_transaction.update!(transaction_type: nil, meta_data: nil)
      head :ok
    end

    private

    def bank_transaction
      @bank_transaction ||= @legal_aid_application.bank_transactions.find(params[:id])
    end
  end
end
