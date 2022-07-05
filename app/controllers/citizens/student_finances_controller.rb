module Citizens
  class StudentFinancesController < CitizenBaseController
    def show
      @form = ::StudentFinances::AnnualAmountForm.new(model: irregular_income)
    end

    def update
      @form = ::StudentFinances::AnnualAmountForm.new(form_params)
      if @form.save
        legal_aid_application.update!(student_finance:)
        go_forward
      else
        render :show
      end
    end

  private

    def irregular_income
      legal_aid_application.irregular_incomes.find_by(income_type: "student_loan")
    end

    def form_params
      merge_with_model(irregular_income) do
        return {} unless params[:irregular_income]

        params.require(:irregular_income).permit(:amount, :student_finance).merge({ income_type: "student_loan", frequency: "annual", legal_aid_application_id: legal_aid_application.id })
      end
    end

    def student_finance
      @student_finance ||= params[:irregular_income][:student_finance]
    end
  end
end
