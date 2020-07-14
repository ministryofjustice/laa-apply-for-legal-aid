module Citizens
  class AdditionalAccountsController < CitizenBaseController
    def index
      legal_aid_application.update!(has_offline_accounts: nil)
      legal_aid_application.applicant_enter_means! unless legal_aid_application.applicant_entering_means?
    end

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
      case params[:has_online_accounts]
      when 'yes'
        online_accounts_update
        redirect_to citizens_banks_path
      when 'no'
        offline_accounts_update
        go_forward
      else
        @error = I18n.t('generic.errors.yes_or_no')
        render :new
      end
    end

    private

    def online_accounts_update
      legal_aid_application.update(has_offline_accounts: false)
    end

    def offline_accounts_update
      legal_aid_application.update(has_offline_accounts: true)
      legal_aid_application.use_ccms! unless legal_aid_application.use_ccms?
    end
  end
end
