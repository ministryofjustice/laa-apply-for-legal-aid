module Providers
  module Means
    class UnexpectedEmploymentIncomesController < ProviderBaseController
      before_action :employments_and_payments

      def show
        @applicant = applicant
        @form = LegalAidApplications::UnexpectedEmploymentIncomeForm.new(model: legal_aid_application)
      end

      def update
        @applicant = applicant
        @form = LegalAidApplications::UnexpectedEmploymentIncomeForm.new(form_params)
        render :show unless save_continue_or_draft(@form)
      end

    private

      def applicant
        @applicant ||= legal_aid_application.applicant
      end

      def employments_and_payments
        @employments = @legal_aid_application.employments
        @eligible_employment_payments = @legal_aid_application.eligible_employment_payments
      end

      def form_params
        merge_with_model(legal_aid_application) do
          return {} unless params[:legal_aid_application]

          params.require(:legal_aid_application).permit(:extra_employment_information_details)
        end
      end
    end
  end
end
