module Providers
  module ApplicationMeritsTask
    class ClientDenialOfAllegationsController < ProviderBaseController
      def show
        @form = ApplicationMeritsTask::ClientDenialOfAllegationForm.new(model: allegation)
      end

      def update
        @form = ApplicationMeritsTask::ClientDenialOfAllegationForm.new(form_params)
        render :show unless update_task_save_continue_or_draft(:application, :client_denial_of_allegation)
      end

    private

      def allegation
        legal_aid_application.allegation || legal_aid_application.build_allegation
      end

      def form_params
        merge_with_model(allegation) do
          params.expect(application_merits_task_allegation: %i[denies_all additional_information])
        end
      end
    end
  end
end
