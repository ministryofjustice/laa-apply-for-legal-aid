module Providers
  module LinkCase
    class ConfirmationsController < ProviderBaseController
      prefix_step_with :link_case

      def show
        @linked_application_types = LinkedApplicationType.all

        if legal_aid_application.copy_case?
          destroy_linked_application
          @form = LinkingCase::ConfirmationForm.new(model: copied_application)
        else
          @form = LinkingCase::ConfirmationForm.new(model: linked_application)
        end
      end

      def update
        @linked_application_types = LinkedApplicationType.all

        if @form.link_type_code.eql?("false")
          destroy_linked_application
        end

        render :show unless save_continue_or_draft(@form, link_case_confirmed: !@form.link_type_code.eql?("false"))
      end

    private

      def destroy_linked_application
        existing_linked_application.destroy! if existing_linked_application
      end

      def existing_linked_application
        LinkedApplication.find_by(associated_application_id: legal_aid_application.id)
      end

      def form_params
        merge_with_model(linked_application) do
          next {} unless params[:linked_application]

          params.require(:linked_application).permit(:link_type_code)
        end
      end

      def copied_application
        @linked_application = LinkedApplication.create!(lead_application_id: legal_aid_application.copy_case_id, associated_application_id: legal_aid_application.id)
      end

      def linked_application
        @linked_application = LinkedApplication.find_by(associated_application_id: legal_aid_application.id)
      end
    end
  end
end
