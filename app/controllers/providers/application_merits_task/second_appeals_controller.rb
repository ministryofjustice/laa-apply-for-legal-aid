module Providers
  module ApplicationMeritsTask
    class SecondAppealsController < ProviderBaseController
      def show
        @form = SecondAppealForm.new(model: appeal)
      end

      def update
        @form = SecondAppealForm.new(form_params)

        render :show unless update_task_save_continue_or_draft(:application, :second_appeal)
      end

    private

      def appeal
        legal_aid_application.appeal || legal_aid_application.build_appeal
      end

      def form_params
        merge_with_model(appeal) do
          params.expect(application_merits_task_appeal: [:second_appeal])
        end
      end
    end
  end
end
