module Citizens
  class BankTransactionsController < ApplicationController
    include ApplicationFromSession
    before_action :authenticate_applicant!

    def remove_transaction_type
      bank_transaction.update! transaction_type: nil
      respond_to do |format|
        format.html do
          redirect_back fallback_location: citizens_identify_types_of_income_path
        end
        format.json { head :ok }
      end
    end

    private

    def bank_transaction
      @bank_transaction ||= BankTransaction.find(params[:id])
    end
  end
end
