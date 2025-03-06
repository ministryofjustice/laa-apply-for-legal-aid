module Providers
  module Means
    class EmploymentIncomesController < ProviderBaseController
      before_action :employments_and_payments

      def show
        @applicant = applicant
        @form = Applicants::EmploymentIncomeForm.new(model: applicant)
      end

      def update
        @applicant = applicant
        @form = Applicants::EmploymentIncomeForm.new(form_params)
        render :show unless save_continue_or_draft(@form)
      end

    private

      def applicant
        @applicant ||= legal_aid_application.applicant
      end

      def employments_and_payments
        @employments = @legal_aid_application.applicant.employments
        @eligible_employment_payments = @legal_aid_application.applicant.eligible_employment_payments
      end

      def form_params
        merge_with_model(applicant) do
          return {} unless params[:applicant]

          params.expect(applicant: [:extra_employment_information, :extra_employment_information_details])
        end
      end
    end
  end
end
