module Providers
  class FullEmploymentDetailsController < ProviderBaseController
    delegate :hmrc_response_use_case_one, to: :legal_aid_application

    def show
      message_sentry if hmrc_still_pending?
      @form = LegalAidApplications::FullEmploymentDetailsForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::FullEmploymentDetailsForm.new(form_params)
      render :show unless save_continue_or_draft(@form)
    end

  private

    def form_params
      merge_with_model(legal_aid_application) do
        return {} unless params[:legal_aid_application]

        params.require(:legal_aid_application).permit(:full_employment_details)
      end
    end

    def message_sentry
      Sentry.capture_message("HMRC response still pending: correlation id: #{correlation_id}")
    end

    def correlation_id
      hmrc_response_use_case_one.correlation_id
    end

    def hmrc_still_pending?
      hmrc_response_use_case_one&.status == "processing"
    end
  end
end
