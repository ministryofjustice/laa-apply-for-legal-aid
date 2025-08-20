module Providers
  module Means
    class CashIncomesController < ProviderBaseController
      before_action :setup_variables, only: %i[show update]

      def show
        @none_selected = legal_aid_application.no_cash_income?
      end

      def update
        if aggregated_cash_income.update(form_params)
          update_no_cash_income(form_params)
          go_forward
        else
          @none_selected = form_params[:none_selected] == "true"
          render :show
        end
      end

    private

      def setup_variables
        cash_transactions
        aggregated_cash_income
      end

      def cash_transactions
        @cash_transactions ||= legal_aid_application.income_cash_transaction_types_for("Applicant")
      end

      def aggregated_cash_income
        return @aggregated_cash_income if defined?(@aggregated_cash_income)

        @aggregated_cash_income = AggregatedCashIncome.find_by(legal_aid_application_id: legal_aid_application.id, owner: "Applicant")
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
