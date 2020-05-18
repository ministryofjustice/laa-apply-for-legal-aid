module Citizens
  class AdditionalAccountsController < CitizenBaseController
    def index; end

    def create
      case params[:additional_account]
      when 'yes'
        redirect_to new_citizens_additional_account_path
      when 'no'
        go_forward
      else
        @error = I18n.t('generic.errors.yes_or_no')
        render :index
      end
    end

    def new; end

    def update
      case params[:has_offline_accounts]
      when 'yes'
        redirect_to citizens_banks_path
      when 'no'
        legal_aid_application.update(has_offline_accounts: true)
        legal_aid_application.use_ccms! unless legal_aid_application.use_ccms?
        go_forward
      else
        @error = I18n.t('generic.errors.yes_or_no')
        render :new
      end
    end
  end
end
