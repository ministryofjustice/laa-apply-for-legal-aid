module Providers
  class HasOtherProceedingsController < ProviderBaseController
    def show
      return go_forward unless Setting.allow_multiple_proceedings?

      @form = Providers::HasOtherProceedingsForm.new
      proceeding_types
    end

    def update
      return continue_or_draft if draft_selected?

      @form = Providers::HasOtherProceedingsForm.new(form_params)
      if @form.valid?
        go_forward(form_params[:has_other_proceedings] == 'true')
      else
        render :show
      end
    end

    def destroy
      remove_proceeding

      if proceeding_types.empty?
        redirect_to providers_legal_aid_application_proceedings_types_path
      else
        @form = Providers::HasOtherProceedingsForm.new
        render :show
      end
    end

    private

    def proceeding_types
      @proceeding_types ||= legal_aid_application.proceeding_types
    end

    def proceeding_type
      proceeding_types.find_by(code: form_params[:id])
    end

    def remove_proceeding
      LegalFramework::RemoveProceedingTypeService.call(legal_aid_application, proceeding_type)
    end

    def form_params
      params[:action] == 'destroy' ? destroy_form_params : update_form_params
    end

    def destroy_form_params
      params.permit(:id)
    end

    def update_form_params
      params.require(:providers_has_other_proceedings_form).permit(:has_other_proceedings)
    end
  end
end
