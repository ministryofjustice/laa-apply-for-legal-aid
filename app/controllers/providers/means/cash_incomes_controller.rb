module Providers
  module Means
    class CashIncomesController < ProviderBaseController
      before_action :aggregated_cash_income, only: %i[show update]

      def show; end

      def update
        if aggregated_cash_income.update(form_params)
          update_no_cash_income(form_params)
          go_forward
        else
          render :show
        end
      end

    private

      def aggregated_cash_income
        @aggregated_cash_income ||= AggregatedCashIncome.find_by(legal_aid_application_id: legal_aid_application.id, owner: "Applicant")
      end

      def form_params
        params
          .require(:aggregated_cash_income)
          .except(:cash_income)
          .merge({
            legal_aid_application_id: legal_aid_application[:id],
            owner_type: "Applicant",
            owner_id: legal_aid_application.applicant.id,
            none_selected: params[:aggregated_cash_income][:none_selected],
          })
      end

      def update_no_cash_income(params)
        val = params.permit(:none_selected)[:none_selected] == "true"
        legal_aid_application.update!(no_cash_income: val)
      end
    end
  end
end
