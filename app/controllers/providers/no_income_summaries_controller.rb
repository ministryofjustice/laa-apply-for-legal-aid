module Providers
  class NoIncomeSummariesController < ProviderBaseController
    def show; end

    def update
      ap params[:confirm_no_income]
      if params[:confirm_no_income].in?(%w[yes no])
        go_forward(params[:confirm_no_income] == 'yes')
      else
        @error = { 'confirm_no_income-error' => I18n.t('providers.no_income_summaries.show.error') }
        render :show
      end
    end
  end
end