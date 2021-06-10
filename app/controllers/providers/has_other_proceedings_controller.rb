module Providers
  class HasOtherProceedingsController < ProviderBaseController
    def show
      return go_forward unless Setting.allow_multiple_proceedings?

      @form = LegalAidApplications::HasOtherProceedingsForm.new(model: legal_aid_application)
      proceeding_types
    end

    def update
      @form = LegalAidApplications::HasOtherProceedingsForm.new(form_params)
      @form.draft! if params[:draft_button]
      if @form.save
        LeadProceedingAssignmentService.call(legal_aid_application)
        return continue_or_draft if draft_selected?

        go_forward(@form.has_other_proceeding?)
      else
        render :show
      end
    end

    def destroy
      remove_proceeding
      remove_laspo_response unless @legal_aid_application.section_8_proceedings?

      return redirect_to providers_legal_aid_application_proceedings_types_path if proceeding_types.empty?

      @form = LegalAidApplications::HasOtherProceedingsForm.new(model: legal_aid_application)
      render :show
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
      LeadProceedingAssignmentService.call(legal_aid_application)
    end

    def remove_laspo_response
      legal_aid_application.in_scope_of_laspo = nil
      legal_aid_application.save!
    end

    def form_params
      params[:action] == 'destroy' ? destroy_form_params : update_form_params
    end

    def destroy_form_params
      params.permit(:id)
    end

    def update_form_params
      merge_with_model(legal_aid_application) do
        return {} unless params[:legal_aid_application]

        params.require(:legal_aid_application).permit(:has_other_proceeding)
      end
    end
  end
end
