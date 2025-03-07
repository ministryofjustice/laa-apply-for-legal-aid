module Providers
  module Partners
    class StudentFinancesController < ProviderBaseController
      prefix_step_with :partner

      def show
        @form = ::Partners::StudentFinanceForm.new(model: partner)
      end

      def update
        @form = ::Partners::StudentFinanceForm.new(form_params)
        render :show unless save_continue_or_draft(@form)
      end

    private

      def partner
        legal_aid_application.partner
      end

      def form_params
        merge_with_model(partner) do
          params.expect(partner: %i[student_finance student_finance_amount])
        end
      end
    end
  end
end
