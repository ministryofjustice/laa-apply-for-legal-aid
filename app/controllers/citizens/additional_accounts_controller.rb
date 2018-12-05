module Citizens
  class AdditionalAccountsController < BaseController
    def index; end

    def create
      case params[:additional_account]
      when 'yes'
        redirect_to new_citizens_additional_account_path
      when 'no'
        # TODO: - set redirect path when known
        render plain: 'Landing page: Next step in Citizen journey'
      else
        @error = I18n.t('generic.errors.yes_or_no')
        render :index
      end
    end

    def new; end

    def update
      case params[:has_offline_accounts]
      when 'yes'
        # TODO: - set redirect path when known
        render plain: 'Landing page: Return to True Layer steps'
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
