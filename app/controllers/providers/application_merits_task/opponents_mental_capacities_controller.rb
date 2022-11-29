module Providers
  module ApplicationMeritsTask
    class OpponentsMentalCapacitiesController < ProviderBaseController
      def show
        @form = Opponents::MentalCapacityForm.new(model: opponent)
      end

      def update
        @form = Opponents::MentalCapacityForm.new(form_params)
        render :show unless update_task_save_continue_or_draft(:application, :opponent_mental_capacity)
      end

    private

      def opponent
        @opponent ||= legal_aid_application.opponent || legal_aid_application.build_opponent
      end

      def form_params
        merge_with_model(opponent) do
          params.require(:application_merits_task_opponent).permit(
            :understands_terms_of_court_order, :understands_terms_of_court_order_details
          )
        end
      end
    end
  end
end
