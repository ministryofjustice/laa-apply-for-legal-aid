module Providers
  module Means
    class StudentFinancesController < ProviderBaseController
      def show
        @form = ::StudentFinances::AnnualAmountForm.new(model: student_finance)
      end

      def update
        @form = ::StudentFinances::AnnualAmountForm.new(student_finance_params)

        if @form.save
          go_forward
        else
          render :show
        end
      end

    private

      def student_finance
        legal_aid_application.irregular_incomes.find_by(income_type: "student_loan")
      end

      def student_finance_params
        merge_with_model(student_finance) do
          params
            .require(:irregular_income)
            .permit(:amount, :student_finance)
            .merge(legal_aid_application:)
        end
      end
    end
  end
end
