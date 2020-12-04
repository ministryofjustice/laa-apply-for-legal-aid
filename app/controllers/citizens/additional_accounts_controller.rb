module Citizens
  class AdditionalAccountsController < CitizenBaseController
    def index
      legal_aid_application.update!(has_offline_accounts: nil)
      legal_aid_application.reset_to_applicant_entering_means! if legal_aid_application.use_ccms?
      legal_aid_application.applicant_enter_means! unless legal_aid_application.applicant_entering_means?
    end

    def create
      case params[:additional_account]
      when 'true'
        redirect_to new_citizens_additional_account_path
      when 'false'
        go_forward
      else
        error('additional_account', 'index')
        render :index
      end
    end

    def new
      legal_aid_application.reset_to_applicant_entering_means! if legal_aid_application.use_ccms?
    end

    def update
      case params[:has_offline_accounts]
      when 'false'
        online_accounts_update
        redirect_to citizens_banks_path
      when 'true'
        offline_accounts_update
        go_forward
      else
        error('has_online_accounts', 'new')
        render :new
      end
    end

    private

    def online_accounts_update
      legal_aid_application.update!(has_offline_accounts: false)
    end

    def offline_accounts_update
      legal_aid_application.update(has_offline_accounts: true)
      legal_aid_application.use_ccms!(:offline_accounts) unless legal_aid_application.use_ccms?
    end

    def error(id, action)
      @error = { "#{id}-error": I18n.t("citizens.additional_accounts.#{action}.error") }
    end
  end
end
