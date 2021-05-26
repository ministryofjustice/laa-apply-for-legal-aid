module Providers
  class HasOtherProceedingsController < ProviderBaseController
    def show
      return go_forward unless Setting.allow_multiple_proceedings?

      form
      proceeding_types
    end

    def update
      return continue_or_draft if draft_selected?

      return go_forward(form.has_other_proceeding?) if go_forward?

      form.errors.add(:has_other_proceeding, I18n.t('providers.has_other_proceedings.show.must_add_domestic_abuse')) unless domestic_abuse_selected?

      render :show
    end

    def destroy
      remove_proceeding
      remove_laspo_response unless @legal_aid_application.section_8_proceedings?

      return redirect_to providers_legal_aid_application_proceedings_types_path if proceeding_types.empty?

      form
      render :show
    end

    private

    def go_forward?
      # go forward if the form is valid AND either there is a dom ab proceeding, or they have selected True to add another proceeding
      form.valid? && (form.has_other_proceeding? || domestic_abuse_selected?)
    end

    def form
      @form ||= BinaryChoiceForm.call(
        journey: :provider,
        radio_buttons_input_name: :has_other_proceeding,
        form_params: update_form_params
      )
    end

    def proceeding_types
      @proceeding_types ||= legal_aid_application.proceeding_types
    end

    def application_proceeding_type
      ApplicationProceedingType.find_by(
        legal_aid_application_id: legal_aid_application.id,
        proceeding_type_id: proceeding_type.id
      )
    end

    def proceeding_type
      proceeding_types.find_by(code: form_params[:id])
    end

    def remove_proceeding
      set_new_lead_proceeding if application_proceeding_type.lead_proceeding? && proceeding_types.count > 1

      LegalFramework::RemoveProceedingTypeService.call(legal_aid_application, proceeding_type)
    end

    def remove_laspo_response
      legal_aid_application.in_scope_of_laspo = nil
      legal_aid_application.save!
    end

    def domestic_abuse_selected?
      proceeding_types.any? { |type| type.ccms_matter == 'Domestic Abuse' }
    end

    def set_new_lead_proceeding
      new_lead = ApplicationProceedingType.where(lead_proceeding: false).find_by(legal_aid_application_id: legal_aid_application.id)
      new_lead.lead_proceeding = true
      new_lead.save!
    end

    def form_params
      params[:action] == 'destroy' ? destroy_form_params : update_form_params
    end

    def destroy_form_params
      params.permit(:id)
    end

    def update_form_params
      return {} unless params[:binary_choice_form]

      params.require(:binary_choice_form).permit(:has_other_proceeding)
    end
  end
end
