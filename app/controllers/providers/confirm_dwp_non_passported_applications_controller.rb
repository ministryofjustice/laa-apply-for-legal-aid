module Providers
  class ConfirmDWPNonPassportedApplicationsController < ProviderBaseController
    include ApplicantDetailsCheckable
    helper_method :display_hmrc_text?

    def show
      delete_check_benefits_from_history
      @form = Providers::ConfirmDWPNonPassportedApplicationsForm.new(model: partner)
    end

    def update
      return continue_or_draft if draft_selected?

      @form = Providers::ConfirmDWPNonPassportedApplicationsForm.new(form_params)

      if @form.valid?
        remove_dwp_override if correct_dwp_result?
        update_joint_benefit_response
        update_application_state
        HMRC::CreateResponsesService.call(legal_aid_application) if make_hmrc_call?
        return go_forward(correct_dwp_result?)
      end

      render :show
    end

  private

    def remove_dwp_override
      legal_aid_application.dwp_override&.destroy!
    end

    def partner
      @partner = legal_aid_application.partner
    end

    def update_joint_benefit_response
      applicant.update!(shared_benefit_with_partner: @form.receives_joint_benefit?)
      return if partner.nil?

      partner.shared_benefit_with_applicant = @form.receives_joint_benefit?
      partner.save!
    end

    def form_params
      merge_with_model(partner) do
        return {} unless params[:partner]

        params.require(:partner).permit(:confirm_dwp_result)
      end
    end

    def update_application_state
      if correct_dwp_result?
        details_checked! unless details_checked?
      else
        legal_aid_application.override_dwp_result! unless legal_aid_application.overriding_dwp_result?
      end
    end

    def delete_check_benefits_from_history
      return if page_history.empty?

      temp_page_history = page_history
      temp_page_history.delete_if { |path| path.include?("check_benefit") }
      page_history_service.write(temp_page_history)
    end

    def correct_dwp_result?
      @form.correct_dwp_result?
    end

    def hmrc_call_enabled?
      Setting.collect_hmrc_data?
    end

    def make_hmrc_call?
      hmrc_call_enabled?
    end

    alias_method :display_hmrc_text?, :make_hmrc_call?
  end
end
