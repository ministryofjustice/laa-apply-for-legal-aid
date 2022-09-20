module Providers
  module ProceedingLoop
    class SubstantiveLevelOfServiceController < ProviderBaseController
      before_action :proceeding
      def show
        @form = Proceedings::SubstantiveLevelOfServiceForm.new(model: proceeding)
      end

      def update
        @form = Proceedings::SubstantiveLevelOfServiceForm.new(form_params)
        render :show unless save_continue_or_draft(@form)
      end

    private

      def proceeding
        @proceeding ||= Proceeding.find(proceeding_id_param)
      end

      def proceeding_id_param
        params.require(:id)
      end

      def form_params
        return { model: proceeding } if form_submitted_without_selection?

        merge_with_model(proceeding) do
          params.require(:proceeding).permit(:substantive_level_of_service)
        end
      end

      def form_submitted_without_selection?
        params[:proceeding].nil?
      end
    end
  end
end
