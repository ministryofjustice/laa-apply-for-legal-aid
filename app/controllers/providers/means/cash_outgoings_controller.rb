module Providers
  module Means
    class CashOutgoingsController < ProviderBaseController
      before_action :aggregated_cash_outgoings, only: %i[show update]

      def show; end

      # TODO: remove nocov and re-enable disabled tests in the
      #  controller once the flow ticket ()AP-3264) is complete
      # :nocov:
      def update
        if aggregated_cash_outgoings.update(form_params)
          update_no_cash_outgoings(form_params)
          go_forward
        else
          render :show
        end
      end

    private

      def aggregated_cash_outgoings
        @aggregated_cash_outgoings ||= AggregatedCashOutgoings.find_by(legal_aid_application_id: legal_aid_application.id)
      end

      def form_params
        params
          .require(:aggregated_cash_outgoings)
          .except(:cash_outgoings)
          .merge({ legal_aid_application_id: legal_aid_application[:id],
                   none_selected: params[:aggregated_cash_outgoings][:none_selected] })
      end

      def update_no_cash_outgoings(params)
        val = params.permit(:none_selected)[:none_selected] == "true"
        legal_aid_application.update!(no_cash_outgoings: val)
      end
      # :nocov:
    end
  end
end
