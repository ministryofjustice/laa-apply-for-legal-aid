module Providers
  module DWP
    class PartnerOverridesController < ProviderBaseController
      prefix_step_with :dwp

      include ApplicantDetailsCheckable

      def show
        @form = Providers::DWP::OverridesForm.new(model: partner)
      end

      def update
        return continue_or_draft if draft_selected?

        @form = Providers::DWP::OverridesForm.new(form_params)

        if @form.valid?
          update_joint_benefit_response
          update_application_state
          HMRC::CreateResponsesService.call(legal_aid_application) if make_hmrc_call?
          return go_forward
        end

        render :show
      end

    private

      def partner
        @partner = legal_aid_application.partner
      end

      def form_params
        merge_with_model(partner) do
          return {} unless params[:partner]

          params.expect(partner: [:confirm_dwp_result])
        end
      end

      def update_joint_benefit_response
        applicant.update!(shared_benefit_with_partner: @form.receives_joint_benefit?)
        return if partner.nil?

        partner.shared_benefit_with_applicant = @form.receives_joint_benefit?
        partner.save!
      end

      def update_application_state
        legal_aid_application.override_dwp_result! unless legal_aid_application.overriding_dwp_result?
      end
    end
  end
end
