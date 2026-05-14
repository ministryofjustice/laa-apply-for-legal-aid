module Providers
  module Means
    class FullEmploymentDetailsController < ProviderBaseController
      delegate :hmrc_response_use_case_one, to: :legal_aid_application

      def show
        message_sentry if hmrc_still_pending?
        @form = Applicants::FullEmploymentDetailsForm.new(model: legal_aid_application)
      end

      def update
        @form = Applicants::FullEmploymentDetailsForm.new(form_params)
        render :show unless save_continue_or_draft(@form)
      end

    private

      def applicant
        @applicant ||= legal_aid_application.applicant
      end

      def form_params
        merge_with_model(applicant) do
          return {} unless params[:applicant]

          params.expect(applicant: [:full_employment_details])
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
