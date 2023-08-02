module Providers
  module Means
    class StudentFinancesController < ProviderBaseController
      def show
        @form = ::Applicants::StudentFinanceForm.new(model: applicant)
      end

      def update
        @form = ::Applicants::StudentFinanceForm.new(student_finance_params)

        if @form.save
          remove_student_finance_amount unless applicant.student_finance
          go_forward
        else
          render :show
        end
      end

    private

      def student_finance
        legal_aid_application.applicant.student_finance
      end

      def student_finance_amount
        legal_aid_application.applicant.student_finance_amount.to_f
      end

      def remove_student_finance_amount
        legal_aid_application.applicant.student_finance_amount = nil
        legal_aid_application.applicant.save!
      end

      def student_finance_params
        merge_with_model(applicant) do
          params.require(:applicant).permit(:student_finance, :student_finance_amount)
        end
      end
    end
  end
end
