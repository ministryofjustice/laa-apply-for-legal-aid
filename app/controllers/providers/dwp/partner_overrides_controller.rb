module Providers
  module DWP
    class PartnerOverridesController < ProviderBaseController
      prefix_step_with :dwp

      include DWPOutcomeHelper

      def show
        checking_dwp_status!(legal_aid_application)
        @form = Providers::DWP::PartnerOverridesForm.new(model: partner)
      end

      def update
        return continue_or_draft if draft_selected?

        @form = Providers::DWP::PartnerOverridesForm.new(form_params)

        if @form.valid?
          update_joint_benefit_response
          update_application_state
          return go_forward
        end

        render :show
      end

    private

      def partner
        @partner = legal_aid_application.partner
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

      def form_params
        merge_with_model(partner) do
          return {} unless params[:partner]

          params.expect(partner: [:confirm_dwp_result])
        end
      end
    end
  end
end
