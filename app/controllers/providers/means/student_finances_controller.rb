module Providers
  module Means
    class StudentFinancesController < ProviderBaseController
      def show
        @receives_student_finance = student_finance?
        @form = ::Applicants::StudentFinanceForm.new(model: applicant)
      end

      def update
        @form = ::Applicants::StudentFinanceForm.new(student_finance_params)

        if @form.save
          remove_student_finance_amount unless student_finance?
          go_forward unless save_continue_or_draft(@form)
        else
          render :show
        end
      end

    private

      def student_finance?
        applicant.student_finance
      end

      def remove_student_finance_amount
        applicant.student_finance_amount = nil
        applicant.save!
      end

      def student_finance_params
        merge_with_model(applicant) do
          params.require(:applicant).permit(:student_finance, :student_finance_amount)
        end
      end
    end
  end
end
