module Providers
  module ApplicationMeritsTask
    class OpponentsNamesController < ProviderBaseController
      def show
        @form = Opponents::NameForm.new(model: opponent)
      end

      def new
        @form = Opponents::NameForm.new(model: opponent)
      end

      def update
        @form = Opponents::NameForm.new(form_params)
        render :show unless update_task_save_continue_or_draft(:application, :opponent_name)
      end

    private

      def opponent
        @opponent ||= opponent_exists? || build_new_opponent
      end

      def opponent_exists?
        legal_aid_application.opponents.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        false
      end

      def build_new_opponent
        ::ApplicationMeritsTask::Opponent.new(legal_aid_application:)
      end

      def form_params
        merge_with_model(opponent) do
          params.require(:application_merits_task_opponent).permit(
            :first_name, :last_name
          )
        end
      end
    end
  end
end
