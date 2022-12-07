module Providers
  module ProceedingLoop
    class DelegatedFunctionsController < ProviderBaseController
      include PreDWPCheckVisible
      before_action :proceeding

      def show
        @form = Proceedings::DelegatedFunctionsForm.new(model: proceeding)
      end

      def update
        @form = Proceedings::DelegatedFunctionsForm.new(form_params)
        DelegatedFunctionsDateService.call(legal_aid_application, draft_selected: draft_selected?)
        reset_proceeding_loop if @legal_aid_application.checking_answers? && Setting.enable_loop?
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

      def reset_proceeding_loop
        proceeding.update!(
          accepted_emergency_defaults: nil,
          accepted_substantive_defaults: nil,
        )
        proceeding.legal_aid_application.update!(
          emergency_cost_requested: nil,
          emergency_cost_reasons: nil,
          substantive_cost_requested: nil,
          substantive_cost_reasons: nil,
        )
      end
    end
  end
end
