module Providers
  module ApplicationMeritsTask
    class OpponentsMentalCapacitiesController < ProviderBaseController
      def show
        @form = Opponents::MentalCapacityForm.new(model: parties_mental_capacity)
      end

      def update
        @form = Opponents::MentalCapacityForm.new(form_params)
        render :show unless update_task_save_continue_or_draft(:application, :opponent_mental_capacity)
      end

    private

      def parties_mental_capacity
        @parties_mental_capacity ||= legal_aid_application.parties_mental_capacity || legal_aid_application.build_parties_mental_capacity
      end

      def form_params
        merge_with_model(parties_mental_capacity) do
          params.expect(
            application_merits_task_parties_mental_capacity: %i[understands_terms_of_court_order understands_terms_of_court_order_details]
          )
        end
      end
    end
  end
end
