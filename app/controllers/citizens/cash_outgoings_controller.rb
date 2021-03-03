module Citizens
  class CashOutgoingsController < CitizenBaseController
    before_action :aggregated_cash_outgoings, only: %i[show update]

    def show; end

    def update
      if aggregated_cash_outgoings.update(form_params)
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
        .merge({
                 legal_aid_application_id: legal_aid_application[:id],
                 none_selected: params[:aggregated_cash_outgoings][:none_selected]
               })
    end
  end
end
