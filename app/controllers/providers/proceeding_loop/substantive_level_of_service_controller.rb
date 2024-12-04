module Providers
  module ProceedingLoop
    class SubstantiveLevelOfServiceController < ProviderBaseController
      before_action :proceeding
      def show
        @form = Proceedings::SubstantiveLevelOfServiceForm.new(model: proceeding)
      end

      def update
        @form = Proceedings::SubstantiveLevelOfServiceForm.new(form_params)
        default = JSON.parse(LegalFramework::ProceedingTypes::Defaults.call(proceeding, false))["default_level_of_service"]["level"].to_s
        changed_to_full_rep = @form.attributes["substantive_level_of_service"] == "3" && @form.attributes["substantive_level_of_service"] != default

        render :show unless save_continue_or_draft(@form, work_type: :substantive, changed_to_full_rep:)
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
