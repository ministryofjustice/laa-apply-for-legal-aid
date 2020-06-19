module Citizens
  module StudentFinances
    class AnnualAmountsController < CitizenBaseController
      prefix_step_with :student_finances

      def show
        @form = LegalAidApplications::StudentFinances::AnnualAmountForm.new(model: irregular_income)
      end

      def update
        @form = StudentFinanceForm::AnnualAmountForm.new(form_params)
        render :show unless save_continue_or_draft(@form)
      end

      private

      def irregular_income
        @irregular_income ||= IrregularIncome.new
      end
    end
  end
end
