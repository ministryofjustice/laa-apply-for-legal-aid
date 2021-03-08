module Providers
  class ConfirmDWPNonPassportedApplicationsController < ProviderBaseController
    def show; end

    def update
      if dwp_results_correct.present?
        go_forward(dwp_results_correct == 'true')
      else
        @error = { 'confirm_dwp_non_passported_applications-error' => I18n.t('providers.confirm_dwp_non_passported_applications.show.error') }
        render :show
      end
    end

    private

    def dwp_results_correct
      @dwp_results_correct ||= params[:dwp_results_correct]
    end
  end
end
