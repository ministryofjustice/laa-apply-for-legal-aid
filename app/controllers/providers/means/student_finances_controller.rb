module Providers
  module Means
    class StudentFinancesController < ProviderBaseController
      def show
        @form = ::StudentFinances::AnnualAmountForm.new(model: irregular_income)
      end

      # :nocov:
      # Can be tested once this controller is added to a flow
      def update
        @form = ::StudentFinances::AnnualAmountForm.new(form_params)
        if student_finance
          legal_aid_application.update!(student_finance:)
          if student_finance == "false" || @form.save
            return go_forward
          end
        else
          @form.errors.add(:student_finance, I18n.t("activemodel.errors.models.legal_aid_application.attributes.student_finance.blank"))
        end
        render :show
      end
    # :nocov:

    private

      # :nocov:
      def irregular_income
        legal_aid_application.irregular_incomes.find_by(income_type: "student_loan")
      end

      def form_params
        merge_with_model(irregular_income) do
          return {} unless params[:irregular_income]

          params.require(:irregular_income).permit(:amount).merge({ income_type: "student_loan", frequency: "annual", legal_aid_application_id: legal_aid_application.id })
        end
      end

      def student_finance
        @student_finance ||= params[:irregular_income][:student_finance]
      end
      # :nocov:
    end
  end
end
