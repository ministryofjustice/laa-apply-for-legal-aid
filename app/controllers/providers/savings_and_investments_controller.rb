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

    def back_step_url
      if legal_aid_application.own_home_no?
        providers_legal_aid_application_own_home_path(legal_aid_application)
      elsif legal_aid_application.shared_ownership?
        providers_legal_aid_application_percentage_home_path(legal_aid_application)
      else
        providers_legal_aid_application_shared_ownership_path(legal_aid_application)
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
