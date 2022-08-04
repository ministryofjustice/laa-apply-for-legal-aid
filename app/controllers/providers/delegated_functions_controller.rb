module Providers
  class DelegatedFunctionsController < ProviderBaseController
    include PreDWPCheckVisible
    before_action :proceeding

    def show
      @form = Proceedings::DelegatedFunctionsForm.new(model: proceeding)
    end

    def update
      @form = Proceedings::DelegatedFunctionsForm.new(form_params)
      render :show unless save_continue_or_draft(@form)
    end

  private

    def proceeding
      @proceeding = Proceeding.find(proceeding_id_param)
    end

    def proceeding_id_param
      params.require(:id)
    end

    def form_params
      merged_params = merge_with_model(proceeding) do
        return {} unless params[:proceeding]

        params.require(:proceeding).permit(:used_delegated_functions,
                                           :used_delegated_functions_on)
      end
      convert_date_params(merged_params)
    end
  end
end
