module Providers
  module Means
    class StudentFinancesController < ProviderBaseController
      def show
        @form = ::Applicants::StudentFinanceForm.new(model: applicant)
      end

      def update
        @form = ::Applicants::StudentFinanceForm.new(form_params)
        render :show unless save_continue_or_draft(@form)
      end

    private

      def applicant
        legal_aid_application.applicant
      end

      def form_params
        merge_with_model(applicant) do
          params.require(:applicant).permit(:student_finance, :student_finance_amount)
        end
      end
    end
  end
end
