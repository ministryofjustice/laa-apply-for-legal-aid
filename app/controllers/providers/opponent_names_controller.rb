module Providers
  class OpponentNamesController < ProviderBaseController
    def show
      @form = Opponents::OpponentNameForm.new(model: opponent)
    end

    def update
      @form = Opponents::OpponentNameForm.new(form_params)
      render :show unless save_continue_or_draft(@form)
    end

    private

    def opponent
      @opponent ||= legal_aid_application.opponent || legal_aid_application.build_opponent
    end

    def form_params
      merge_with_model(opponent) do
        params.require(:application_merits_task_opponent).permit(:full_name)
      end
    end
  end
end
