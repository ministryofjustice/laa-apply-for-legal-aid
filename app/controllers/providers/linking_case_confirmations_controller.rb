module Providers
  class LinkingCaseConfirmationsController < ProviderBaseController
    def show
      @form = LinkingCase::ConfirmationForm.new(model: linked_application)
    end

    def update
      @form = LinkingCase::ConfirmationForm.new(form_params)

      if @form.link_type_code.eql?("false")
        destroy_linked_application
      end

      render :show unless save_continue_or_draft(@form)
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
        params.require(:linked_application).permit(:link_type_code)
      end
    end

    def linked_application
      @linked_application = LinkedApplication.find_by(associated_application_id: legal_aid_application.id)
    end
  end
end
