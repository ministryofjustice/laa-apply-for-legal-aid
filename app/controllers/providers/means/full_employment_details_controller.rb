module Providers
  module Means
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

          params.expect(legal_aid_application: [:full_employment_details])
        end
      end

      def message_sentry
        Sentry.capture_message("HMRC response still pending")
      end

      def hmrc_still_pending?
        return true if hmrc_response_use_case_one.nil?

        hmrc_response_use_case_one.status == "processing"
      end
    end
  end
end
