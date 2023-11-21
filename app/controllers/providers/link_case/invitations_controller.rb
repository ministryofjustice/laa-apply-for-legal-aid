module Providers
  module LinkCase
    class InvitationsController < ProviderBaseController
      prefix_step_with :link_case

      def show
        @form = ::LinkCase::InvitationForm.new(model: legal_aid_application)
      end

      def update
        @form = ::LinkCase::InvitationForm.new(form_params)

        render :show unless save_continue_or_draft(@form)
      end

    private

      def form_params
        merge_with_model(legal_aid_application) do
          next {} unless params[:legal_aid_application]

          params.require(:legal_aid_application).permit(:link_case)
        end
      end
    end
  end
end
