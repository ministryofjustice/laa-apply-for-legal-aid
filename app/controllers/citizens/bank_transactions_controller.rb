module Citizens
  class BankTransactionsController < ApplicationController
    include ApplicationFromSession
    before_action :authenticate_applicant!

    def remove_transation_type
      bank_transaction.update! transaction_type: nil
      redirect_back fallback_location: citizens_identify_types_of_income_path
    end

    private

    def bank_transaction
      @bank_transaction ||= BankTransaction.find(params[:id])
    end
  end
end
