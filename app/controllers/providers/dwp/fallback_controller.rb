module Providers
  module DWP
    class FallbackController < ProviderBaseController
      prefix_step_with :dwp

      include ApplicantDetailsCheckable
      include DWPOutcomeHelper

      def show
        @form = Providers::DWP::FallbackForm.new(model: partner)
        reset_confirm_dwp_status!(legal_aid_application)
      end

      def update
        confirm_dwp_status_correct!(legal_aid_application)
        return continue_or_draft if draft_selected?

        @form = Providers::DWP::FallbackForm.new(form_params)

        if @form.valid?
          remove_dwp_override if correct_dwp_result?
          update_joint_benefit_response
          update_application_state
          HMRC::CreateResponsesService.call(legal_aid_application) if make_hmrc_call?
          return go_forward(confirm_receipt_of_benefit?)
        end

        render :show
      end

    private

      def partner
        @partner = legal_aid_application.partner
      end

      def remove_dwp_override
        legal_aid_application.dwp_override&.destroy!
      end

      def update_joint_benefit_response
        applicant.update!(shared_benefit_with_partner: @form.receives_joint_benefit?)
        return if partner.nil?

        partner.shared_benefit_with_applicant = @form.receives_joint_benefit?
        partner.save!
      end

      def update_application_state
        if correct_dwp_result?
          details_checked! unless details_checked?
        else
          legal_aid_application.override_dwp_result! unless legal_aid_application.overriding_dwp_result?
        end
      end

      def confirm_receipt_of_benefit?
        @form.confirm_receipt_of_benefit?
      end

      def correct_dwp_result?
        @form.correct_dwp_result?
      end

      def form_params
        merge_with_model(partner) do
          return { model: partner } unless params[:partner]

          params.permit(partner: [:confirm_dwp_result], model: partner).require(:partner)
        end
      end
    end
  end
end
