module Providers
  class ConfirmOfficesController < ProviderBaseController
    legal_aid_application_not_required!
    helper_method :firm

    def show
      initialize_page_history
      next_page = determine_where_next
      redirect_to next_page unless next_page.nil?
    end

    def update
      case params[:correct]
      when 'yes'
        redirect_to providers_legal_aid_applications_path
      when 'no'
        current_provider.update!(selected_office: nil)
        redirect_to providers_select_office_path
      else
        @error = I18n.t('providers.confirm_offices.show.error')
        render :show
      end
    end

    def invalid_login; end

    private

    def determine_where_next
      return providers_invalid_login_path if current_provider.invalid_login?

      if firm.offices.count == 1
        current_provider.update!(selected_office: firm.offices.first)
        return providers_legal_aid_applications_path
      end

      return providers_select_office_path unless current_provider.selected_office

      nil
    end

    def firm
      current_provider.firm
    end

    def initialize_page_history
      session[:page_history_id] = SecureRandom.uuid
    end
  end
end
