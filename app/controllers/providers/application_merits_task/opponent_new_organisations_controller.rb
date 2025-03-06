module Providers
  module ApplicationMeritsTask
    class OpponentNewOrganisationsController < ProviderBaseController
      def show
        @form = Opponents::OrganisationForm.new(model: opponent, name: opponent.name, organisation_type_ccms_code: opponent.ccms_type_code)
      end

      def new
        @form = Opponents::OrganisationForm.new(model: opponent)
      end

      def update
        @form = Opponents::OrganisationForm.new(form_params)
        render :show unless update_task_save_continue_or_draft(:application, :opponent_name)
      end

    private

      def opponent
        @opponent ||= existing_opponent || build_new_opponent
      end

      def existing_opponent
        legal_aid_application.opponents.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        nil
      end

      def build_new_opponent
        ::ApplicationMeritsTask::Organisation.new.build_opponent(legal_aid_application:)
      end

      def form_params
        merge_with_model(opponent) do
          params.expect(
            application_merits_task_opponent: %i[name organisation_type_ccms_code],
          )
        end
      end
    end
  end
end
