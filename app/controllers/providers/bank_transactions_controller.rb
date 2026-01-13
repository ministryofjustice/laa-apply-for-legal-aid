module Providers
  class BankTransactionsController < ProviderBaseController
    def remove_transaction_type
      bank_transaction.update!(transaction_type: nil, meta_data: nil)

      flash[:hash] = success_hash

      respond_to do |format|
        format.js
        format.html { redirect_back_or_to(providers_root_path) }
      end
    end

  private

    def bank_transaction
      @bank_transaction ||= @legal_aid_application.bank_transactions.find(params[:id])
    end

    def success_hash
      {
        title_text: t("generic.success"),
        success: true,
        heading_text: removal_confirmation_message,
      }
    end

    def removal_confirmation_message
      I18n.t("providers.bank_transactions.list_selected.removal_confirmation",
             happened_at: l(bank_transaction.happened_at.to_date, format: :short_date),
             description: bank_transaction.description)
    end
  end
end
