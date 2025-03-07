module Providers
  module ApplicationMeritsTask
    class MatterOpposedReasonsController < ProviderBaseController
      def show
        @form = MatterOpposedReasonForm.new(model: matter_opposition)
      end

      def update
        @form = MatterOpposedReasonForm.new(matter_opposition_params)

        unless update_task_save_continue_or_draft(:application, :why_matter_opposed)
          render :show
        end
      end

    private

      def matter_opposition
        legal_aid_application.matter_opposition ||
          legal_aid_application.build_matter_opposition
      end

      def matter_opposition_params
        merge_with_model(matter_opposition) do
          params
            .expect(application_merits_task_matter_opposition: [:reason])
            .merge(legal_aid_application_id: legal_aid_application.id)
        end
      end
    end
  end
end
