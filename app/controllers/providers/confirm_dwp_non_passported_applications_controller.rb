module Providers
  class ConfirmDWPNonPassportedApplicationsController < ProviderBaseController
    def show; end

    def update
      return continue_or_draft if draft_selected?

      if dwp_results_correct.present?
        details_checked! if correct_dwp_result? && !details_checked?
        go_forward(correct_dwp_result?)
      else
        @error = { 'confirm_dwp_non_passported_applications-error' => I18n.t('providers.confirm_dwp_non_passported_applications.show.error') }
        render :show
      end
    end

    private

    def details_checked!
      legal_aid_application.applicant_details_checked!
    end

    def details_checked?
      legal_aid_application.applicant_details_checked?
    end

    def correct_dwp_result?
      dwp_results_correct == 'true'
    end

    def dwp_results_correct
      @dwp_results_correct ||= params[:dwp_results_correct]
    end
  end
end
