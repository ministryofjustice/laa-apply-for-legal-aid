module Providers
  class DelegatedFunctionsDatesController < ProviderBaseController
    include PreDWPCheckVisible

    def show
      @used_delegated_functions_on = legal_aid_application.used_delegated_functions_on
      @form = LegalAidApplications::DelegatedFunctionsDateForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::DelegatedFunctionsDateForm.new(form_params)
      if save_continue_or_draft(@form)
        submit_application_reminder
      else
        render :show
      end
    end

    private

    def submit_application_reminder
      return if legal_aid_application.awaiting_applicant?
      return if legal_aid_application.applicant_entering_means?
      return unless @form.model.used_delegated_functions?

      SubmitApplicationReminderService.new(legal_aid_application).send_email
    end

    def form_params
      merge_with_model(legal_aid_application) do
        params.require(:legal_aid_application).permit(
          :used_delegated_functions_year,
          :used_delegated_functions_month,
          :used_delegated_functions_day,
          :confirm_delegated_functions_date
        )
      end
    end
  end
end
