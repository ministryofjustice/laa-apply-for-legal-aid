module Providers
  module Partners
    class StudentFinancesController < ProviderBaseController
      prefix_step_with :partner

      def show
        @receives_student_finance = student_finance?
        @form = ::Partners::StudentFinanceForm.new(model: partner)
      end

      def update
        @form = ::Partners::StudentFinanceForm.new(student_finance_params)
        remove_student_finance_amount unless @form.student_finance?
        render :show unless save_continue_or_draft(@form)
      end

    private

      def partner
        legal_aid_application.partner
      end

      def student_finance?
        partner.student_finance
      end

      def remove_student_finance_amount
        partner.student_finance_amount = nil
        partner.save!
      end

      def student_finance_params
        merge_with_model(partner) do
          params.require(:partner).permit(:student_finance, :student_finance_amount)
        end
      end
    end
  end
end
