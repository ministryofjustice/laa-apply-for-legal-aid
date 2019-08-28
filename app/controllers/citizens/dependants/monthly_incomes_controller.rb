module Citizens
  module Dependants
    class MonthlyIncomesController < CitizenBaseController
      prefix_step_with :dependants

      def show
        @form = DependantForm::MonthlyIncomeForm.new(model: dependant)
      end

      def update
        @form = DependantForm::MonthlyIncomeForm.new(form_params)

        if @form.save
          go_forward(dependant)
        else
          render :show
        end
      end

      private

      def dependant
        @dependant ||= legal_aid_application.dependants.find(params[:dependant_id])
      end

      def form_params
        merge_with_model(dependant) do
          params.require(:dependant).permit(:has_income, :monthly_income)
        end
      end
    end
  end
end
