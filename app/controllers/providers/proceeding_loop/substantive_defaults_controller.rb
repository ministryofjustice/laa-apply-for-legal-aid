module Providers
  module ProceedingLoop
    class SubstantiveDefaultsController < ProviderBaseController
      before_action :proceeding

      def show
        @form = Proceedings::SubstantiveDefaultsForm.new(model: proceeding)
      end

      def update
        @form = Proceedings::SubstantiveDefaultsForm.new(form_params)
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
          params.expect(proceeding: %i[accepted_substantive_defaults
                                     substantive_level_of_service
                                     substantive_level_of_service_name
                                     substantive_level_of_service_stage
                                     substantive_scope_limitation_meaning
                                     substantive_scope_limitation_description
                                     substantive_scope_limitation_code])
        end
      end

      def form_submitted_without_selection?
        params[:proceeding].nil?
      end
    end
  end
end
