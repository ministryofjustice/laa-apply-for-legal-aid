module Providers
  module Means
    class CashOutgoingsController < ProviderBaseController
      before_action :setup_cash_outgoings, only: %i[show update]

      def show
        @none_selected = legal_aid_application.no_cash_outgoings?
      end

      def update
        if aggregated_cash_outgoings.update(form_params)
          update_no_cash_outgoings(form_params)
          go_forward
        else
          @none_selected = form_params[:none_selected] == "true"
          render :show
        end
      end

    private

      def setup_cash_outgoings
        cash_transactions
        aggregated_cash_outgoings
      end

      def cash_transactions
        @cash_transactions ||= legal_aid_application.outgoing_cash_transaction_types_for("Applicant")
      end

      def aggregated_cash_outgoings
        return @aggregated_cash_outgoings if defined?(@aggregated_cash_outgoings)

        @aggregated_cash_outgoings = AggregatedCashOutgoings.find_by(legal_aid_application_id: legal_aid_application.id, owner: "Applicant")
      end

      def form_params
        params
          .require(:aggregated_cash_outgoings)
          .except(:cash_outgoings)
          .merge({ legal_aid_application_id: legal_aid_application[:id],
                   owner_type: "Applicant",
                   owner_id: legal_aid_application.applicant.id,
                   none_selected: params[:aggregated_cash_outgoings][:none_selected] })
      end

      def update_no_cash_outgoings(params)
        val = params.permit(:none_selected)[:none_selected] == "true"
        legal_aid_application.update!(no_cash_outgoings: val)
      end
    end
  end
end
