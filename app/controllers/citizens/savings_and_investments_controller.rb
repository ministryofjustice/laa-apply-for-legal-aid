module Citizens
  class SavingsAndInvestmentsController < BaseController
    before_action :bank_accounts, :back_link

    def show
      @form = SavingsAmounts::SavingsAmountsForm.new(current_params)
    end

    def update
      @form = SavingsAmounts::SavingsAmountsForm.new(form_params.merge(model: savings_amount))

      if @form.save
        render plain: 'Navigate to question 3a. Other capital assets'
      else
        render :show
      end
    end

    private

    def back_link
      @back_link ||= citizens_own_home_path

      # TODO
      # 1a for people that answered No to 1a
      # 1d for people that answered either Yes on 1a and No on 1d
      # 1e for people that answered either Yes on 1a and Yes on 1d
    end

    def attributes
      @attributes ||= SavingsAmounts::SavingsAmountsForm::ATTRIBUTES
    end

    def check_box_attributes
      @check_box_attributes ||= SavingsAmounts::SavingsAmountsForm::CHECK_BOXES_ATTRIBUTES
    end

    def bank_accounts
      @bank_accounts ||= legal_aid_application.applicant.bank_providers.flat_map(&:bank_accounts)
    end

    def current_params
      savings_amount.attributes.symbolize_keys.slice(*attributes)
    end

    def savings_amount
      @savings_amount ||= legal_aid_application.savings_amount || legal_aid_application.build_savings_amount
    end

    def legal_aid_application
      @legal_aid_application ||= LegalAidApplication.find(session[:current_application_ref])
    end

    def form_params
      params.require(:savings_amount).permit(attributes + check_box_attributes)
    end
  end
end
