module Citizens
  class SavingsAndInvestmentsController < BaseController
    include ApplicationFromSession
    helper_method :bank_accounts, :attributes

    def show
      @form = SavingsAmounts::SavingsAmountsForm.new(model: savings_amount)
    end

    def update
      @form = SavingsAmounts::SavingsAmountsForm.new(form_params)
      return go_forward if @form.save

      render :show
    end

    private

    def bank_accounts
      @bank_accounts ||= legal_aid_application.applicant.bank_providers.flat_map(&:bank_accounts)
    end

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
      merge_with_model(savings_amount, journey: journey_type) do
        params.require(:savings_amount).permit(attributes + check_box_attributes)
      end
    end
  end
end
