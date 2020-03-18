module Providers
  class OfflineAccountsController < ProviderBaseController
    helper_method :attributes

    def show
      @form = SavingsAmounts::OfflineAccountsForm.new(model: savings_amount)
    end

    def update
      @form = SavingsAmounts::OfflineAccountsForm.new(form_params)

      render :show unless save_continue_or_draft(@form)
    end

    private

    def attributes
      @attributes ||= SavingsAmounts::OfflineAccountsForm::ATTRIBUTES
    end

    def check_box_attributes
      SavingsAmounts::OfflineAccountsForm::CHECK_BOXES_ATTRIBUTES
    end

    def savings_amount
      @savings_amount ||= legal_aid_application.savings_amount || legal_aid_application.build_savings_amount
    end

    def form_params
      merge_with_model(savings_amount, journey: journey_type) do
        params.require(:savings_amount).permit(attributes + check_box_attributes)
      end
    end
  end
end
