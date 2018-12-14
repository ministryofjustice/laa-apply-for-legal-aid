module Citizens
  class AdditionalAccountsController < BaseController
    def index; end

    def create
      case params[:additional_account]
      when 'yes'
        redirect_to new_citizens_additional_account_path
      when 'no'
        redirect_to citizens_own_home_path
      else
        @error = I18n.t('generic.errors.yes_or_no')
        render :index
      end
    end

    def new; end

    def update
      case params[:has_offline_accounts]
      when 'yes'
        redirect_to applicant_true_layer_omniauth_authorize_path
      when 'no'
        legal_aid_application.update(has_offline_accounts: true)
        redirect_to citizens_own_home_path
      else
        @error = I18n.t('generic.errors.yes_or_no')
        render :new
      end
    end

    private

    def legal_aid_application
      @legal_aid_application ||= LegalAidApplication.find(session[:current_application_ref])
    end
  end
end
