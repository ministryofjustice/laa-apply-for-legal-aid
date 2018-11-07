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
        flash[:error] = 'You must select either Yes or No'
        render :index
      end
    end

    def new; end

    def update
      case params[:additional_account]
      when 'yes'
        # TODO: - set redirect path when known
        render plain: 'Landing page: Return to True Layer steps'
      when 'no'
        current_legal_aid_application&.update(has_offline_accounts: true)
        # TODO: - set redirect path when known
        render plain: 'Landing page: Next step in Citizen journey'
      else
        flash[:error] = 'You must select either Yes or No'
        render :index
      end
    end
  end
end
