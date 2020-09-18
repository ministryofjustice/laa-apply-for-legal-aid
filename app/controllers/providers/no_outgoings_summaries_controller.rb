module Providers
  class NoOutgoingsSummariesController < ProviderBaseController
    def show; end

    def update
      ap params[:confirm_no_outgoings]
      if params[:confirm_no_outgoings].in?(%w[yes no])
        go_forward(params[:confirm_no_outgoings] == 'yes')
      else
        @error = { 'confirm_no_outgoings-error' => I18n.t('providers.no_outgoings_summaries.show.error') }
        render :show
      end
    end
  end
end