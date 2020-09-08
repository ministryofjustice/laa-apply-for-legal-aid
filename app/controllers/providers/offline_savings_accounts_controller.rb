module Providers
  class OfflineSavingsAccountsController < ProviderBaseController
    def show
      @form = SavingsAmounts::OfflineSavingsAccountsForm.new(model: savings_amount)
    end

    def update
      @form = SavingsAmounts::OfflineSavingsAccountsForm.new(form_params)

      render :show unless save_continue_or_draft(@form)
    end

    private

    def savings_amount
      @savings_amount ||= legal_aid_application.savings_amount || legal_aid_application.build_savings_amount
    end

    def form_params
      merge_with_model(savings_amount) do
        params.require(:savings_amount).permit(:offline_savings_accounts)
      end
    end
  end
end
