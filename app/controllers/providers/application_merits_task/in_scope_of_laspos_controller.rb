module Providers
  module ApplicationMeritsTask
    class InScopeOfLasposController < ProviderBaseController
      def show
        @form = InScopeOfLaspoForm.new(model: legal_aid_application)
        render :show
      end

      def update
        @form = InScopeOfLaspoForm.new(form_params)

        render :show unless update_task_save_continue_or_draft(:application, :laspo)
      end

    private

      def form_params
        merge_with_model(legal_aid_application) do
          return {} unless params[:legal_aid_application]

          params.expect(legal_aid_application: [:in_scope_of_laspo])
        end
      end

      def continue_or_draft
        legal_aid_application.update!(draft: draft_selected?)

        if legal_aid_application.draft?
          redirect_to draft_target_endpoint
        else
          go_forward(legal_aid_application)
        end
      end
    end
  end
end
