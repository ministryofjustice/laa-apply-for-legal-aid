module Providers
  class HasOtherProceedingsController < ProviderBaseController
    def show
      @form = LegalAidApplications::HasOtherProceedingsForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::HasOtherProceedingsForm.new(form_params)
      @form.draft! if params[:draft_button]
      if @form.save
        return continue_or_draft if draft_selected?

        go_forward(@form.has_other_proceeding?)
      else
        render :show
      end
    end

    def destroy
      remove_proceeding
      remove_laspo_response unless @legal_aid_application.section_8_proceedings?

      return redirect_to providers_legal_aid_application_proceedings_types_path if proceedings.empty?

      @form = LegalAidApplications::HasOtherProceedingsForm.new(model: legal_aid_application)
      render :show
    end

  private

    def proceedings
      @proceedings ||= legal_aid_application.proceedings
    end

    def proceeding
      proceedings.find_by(ccms_code: form_params[:ccms_code])
    end

    def remove_proceeding
      LegalFramework::RemoveProceedingService.call(legal_aid_application, proceeding)
      LegalFramework::LeadProceedingAssignmentService.call(legal_aid_application)
    end

    def remove_laspo_response
      legal_aid_application.in_scope_of_laspo = nil
      legal_aid_application.save!
    end

    def form_params
      params[:action] == "destroy" ? destroy_form_params : update_form_params
    end

    def destroy_form_params
      params.permit(:ccms_code)
    end

    def update_form_params
      merge_with_model(legal_aid_application) do
        return {} unless params[:legal_aid_application]

        params.expect(legal_aid_application: [:has_other_proceeding])
      end
    end
  end
end
