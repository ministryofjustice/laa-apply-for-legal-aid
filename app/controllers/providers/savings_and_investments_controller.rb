module Providers
  class SavingsAndInvestmentsController < BaseController
    include ApplicationDependable
    include SaveAsDraftable
    include Steppable
    helper_method :bank_accounts, :attributes

    def show
      @form = SavingsAmounts::SavingsAmountsForm.new(model: savings_amount)
    end

    def update
      @form = SavingsAmounts::SavingsAmountsForm.new(form_params.merge(model: savings_amount))

      if @form.save
        continue_or_save_draft
      else
        render :show
      end
    end

    private

    def attributes
      @attributes ||= SavingsAmounts::SavingsAmountsForm::ATTRIBUTES
    end

    def check_box_attributes
      SavingsAmounts::SavingsAmountsForm::CHECK_BOXES_ATTRIBUTES
    end

    def savings_amount
      @savings_amount ||= legal_aid_application.savings_amount || legal_aid_application.build_savings_amount
    end

    def form_params
      params.require(:savings_amount).permit(attributes + check_box_attributes)
    end
  end
end
