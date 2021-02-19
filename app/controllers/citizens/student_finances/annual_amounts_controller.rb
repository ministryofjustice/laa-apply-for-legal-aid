module Citizens
  module StudentFinances
    class AnnualAmountsController < CitizenBaseController
      prefix_step_with :student_finances

      def show
        @form = ::StudentFinances::AnnualAmountForm.new(model: irregular_income)
      end

      def update
        @form = ::StudentFinances::AnnualAmountForm.new(form_params)

        if @form.save
          go_forward
        else
          render :show
        end
      end

      private

      def irregular_income
        legal_aid_application.irregular_incomes.find_by(income_type: 'student_loan')
      end

      def form_params
        merge_with_model(irregular_income) do
          return {} unless params[:irregular_income]

          params.require(:irregular_income).permit(:amount).merge({ income_type: 'student_loan', frequency: 'annual', legal_aid_application_id: legal_aid_application.id })
        end
      end
    end
  end
end
