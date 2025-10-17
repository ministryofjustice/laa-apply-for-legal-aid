module Providers
  class ReceivedBenefitConfirmationsController < ProviderBaseController
    include ApplicantDetailsCheckable
    include DWPOutcomeHelper

    def show
      @form = Providers::ReceivedBenefitConfirmationForm.new(model: dwp_override)
    end

    def update
      return continue_or_draft if draft_selected?

      @form = Providers::ReceivedBenefitConfirmationForm.new(form_params)

      if @form.valid?
        confirm_dwp_status_correct!(legal_aid_application) unless benefit?
        benefit? ? @form.save! : dwp_override.destroy!
        details_checked! unless details_checked? || benefit?
        go_forward(benefit?)
      else
        render :show
      end
    end

  private

    def benefit?
      form_params[:passporting_benefit] != "none_selected"
    end

    def form_params
      merge_with_model(dwp_override) do
        return {} unless params[:dwp_override]

        params.expect(dwp_override: [:passporting_benefit])
      end
    end

    def dwp_override
      @dwp_override ||= legal_aid_application.dwp_override || legal_aid_application.create_dwp_override!
    end
  end
end
