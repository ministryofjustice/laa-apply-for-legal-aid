module Providers
  module CopyCase
    class ConfirmationsController < ProviderBaseController
      prefix_step_with :copy_case

      def show
        @form = ::CopyCase::ConfirmationForm.new(model: legal_aid_application)
        @copiable_case = LegalAidApplication.find(legal_aid_application.copy_case_id)
      end

      def update
        @form = ::CopyCase::ConfirmationForm.new(form_params)
        @copiable_case = LegalAidApplication.find(form_params[:copy_case_id])

        render :show unless save_continue_or_draft(@form, copy_case_confirmed: @form.copy_case_confirmed?)
      end

    private

      def form_params
        merge_with_model(legal_aid_application) do
          next {} unless params[:legal_aid_application]

          params.require(:legal_aid_application).permit(:copy_case_id, :copy_case_confirmation)
        end
      end
    end
  end
end
