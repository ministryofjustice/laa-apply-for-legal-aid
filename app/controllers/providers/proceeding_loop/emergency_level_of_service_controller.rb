module Providers
  module ProceedingLoop
    class EmergencyLevelOfServiceController < ProviderBaseController
      before_action :proceeding
      def show
        @form = Proceedings::EmergencyLevelOfServiceForm.new(model: proceeding)
      end

      def update
        @form = Proceedings::EmergencyLevelOfServiceForm.new(form_params)
        default = JSON.parse(LegalFramework::ProceedingTypes::Defaults.call(proceeding, true))["default_level_of_service"]["level"].to_s
        changed_to_full_rep = @form.attributes["emergency_level_of_service"] == "3" && @form.attributes["emergency_level_of_service"] != default
        render :show unless save_continue_or_draft(@form, work_type: :emergency, changed_to_full_rep:)
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
          params.expect(proceeding: [:emergency_level_of_service])
        end
      end

      def form_submitted_without_selection?
        params[:proceeding].nil?
      end
    end
  end
end
