module Providers
  module ApplicationMeritsTask
    class OpponentIndividualsController < ProviderBaseController
      def show
        @form = Opponents::IndividualForm.new(model: opponent, first_name: opponent.first_name, last_name: opponent.last_name)
      end

      def new
        @form = Opponents::IndividualForm.new(model: opponent)
      end

      def update
        @form = Opponents::IndividualForm.new(form_params)
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
        ::ApplicationMeritsTask::Individual.new.build_opponent(legal_aid_application:)
      end

      def form_params
        merge_with_model(opponent) do
          params.expect(
            application_merits_task_opponent: [:first_name, :last_name]
          )
        end
      end
    end
  end
end
