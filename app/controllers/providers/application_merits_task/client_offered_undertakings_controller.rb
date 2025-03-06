module Providers
  module ApplicationMeritsTask
    class ClientOfferedUndertakingsController < ProviderBaseController
      def show
        @form = ApplicationMeritsTask::ClientOfferedUndertakingsForm.new(model: undertaking)
      end

      def update
        @form = ApplicationMeritsTask::ClientOfferedUndertakingsForm.new(form_params)
        render :show unless update_task_save_continue_or_draft(:application, :client_offer_of_undertakings)
      end

    private

      def undertaking
        legal_aid_application.undertaking || legal_aid_application.build_undertaking
      end

      def form_params
        merge_with_model(undertaking) do
          params.expect(application_merits_task_undertaking: [:offered, :additional_information_true, :additional_information_false])
        end
      end
    end
  end
end
