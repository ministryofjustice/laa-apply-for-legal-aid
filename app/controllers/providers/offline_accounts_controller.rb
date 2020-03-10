module Providers
  class OfflineAccountsController < ProviderBaseController
    helper_method :attributes

    def show
      @form = SavingsAmounts::OfflineAccountsForm.new(model: savings_amount)
    end

    private

    def attributes
      @attributes ||= SavingsAmounts::OfflineAccountsForm::ATTRIBUTES
    end

    def savings_amount
      @savings_amount ||= legal_aid_application.savings_amount || legal_aid_application.build_savings_amount
    end
  end
end
