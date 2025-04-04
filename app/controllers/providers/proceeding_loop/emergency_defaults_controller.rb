module Providers
  module ProceedingLoop
    class EmergencyDefaultsController < ProviderBaseController
      before_action :proceeding

      def show
        @form = Proceedings::EmergencyDefaultsForm.new(model: proceeding)
      end

      def update
        @form = Proceedings::EmergencyDefaultsForm.new(form_params)
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

        merged_params = merge_with_model(proceeding) do
          params
                .expect(proceeding: %i[accepted_emergency_defaults
                                       emergency_level_of_service
                                       emergency_level_of_service_name
                                       emergency_level_of_service_stage
                                       delegated_functions_scope_limitation_meaning
                                       delegated_functions_scope_limitation_description
                                       delegated_functions_scope_limitation_code
                                       hearing_date])
        end
        convert_date_params(merged_params)
      end

      def form_submitted_without_selection?
        params[:proceeding].nil?
      end
    end
  end
end
