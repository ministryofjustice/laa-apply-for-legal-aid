module Providers
  module ProceedingLoop
    class ClientInvolvementTypeController < ProviderBaseController
      before_action :proceeding

      def show
        @form = Proceedings::ClientInvolvementTypeForm.new(model: proceeding)
      end

      def update
        @form = Proceedings::ClientInvolvementTypeForm.new(form_params)
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
        merge_with_model(proceeding) do
          return {} unless params[:proceeding]

          params.expect(proceeding: [:client_involvement_type_ccms_code])
        end
      end
    end
  end
end
