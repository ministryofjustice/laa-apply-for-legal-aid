module Providers
  class NoOutgoingsSummariesController < ProviderBaseController
    def show; end

    def update
      if params[:confirm_no_outgoings].in?(%w[true false])
        go_forward(params[:confirm_no_outgoings] == 'true')
      else
        @error = { 'confirm_no_outgoings-error' => I18n.t('providers.no_outgoings_summaries.show.error') }
        render :show
      end
    end
  end
end
