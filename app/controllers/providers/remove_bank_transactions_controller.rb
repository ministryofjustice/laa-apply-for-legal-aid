module Providers
  class RemoveBankTransactionsController < ProviderBaseController
    def show
      bank_transaction
      form
    end

    def update
      bank_transaction

      if form.valid?
        bank_transaction.destroy! if form.remove_bank_transaction?

        # go to income/outgoing summary page, or back page
        # replace_last_page_in_history(submitted_providers_legal_aid_applications_path)
        redirect :back
      else
        render :show
      end
    end

  private

    def form
      @form ||= BinaryChoiceForm.call(
        journey: :provider,
        radio_buttons_input_name: :remove_bank_transaction,
        form_params:,
        error: error_message,
      )
    end

    def bank_transaction
      @bank_transaction ||= @legal_aid_application.bank_transactions.find(params[:id])
    end

    def form_params
      return {} unless params[:binary_choice_form]

      params.require(:binary_choice_form).permit(:remove_bank_transaction)
    end

    def error_message
      I18n.t("providers.remove_bank_transactions.show.error")
    end
  end
end
