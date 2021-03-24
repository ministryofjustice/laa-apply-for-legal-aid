module Providers
  class ReceivedBenefitConfirmationsController < ProviderBaseController
    def show
      @form = Providers::ReceivedBenefitConfirmationForm.new(model: dwp_override)
    end

    def update
      return continue_or_draft if draft_selected?

      @form = Providers::ReceivedBenefitConfirmationForm.new(form_params)

      if @form.valid?
        benefit? ? @form.save : dwp_override.destroy!
        details_checked! unless details_checked? || benefit?
        go_forward(benefit?)
      else
        render :show
      end
    end

    private

    def benefit?
      form_params[:passporting_benefit] != 'none_selected'
    end

    def details_checked!
      legal_aid_application.applicant_details_checked!
    end

    def details_checked?
      legal_aid_application.applicant_details_checked?
    end

    def form_params
      merge_with_model(dwp_override) do
        return {} unless params[:dwp_override]

        params.require(:dwp_override).permit(:passporting_benefit)
      end
    end

    def dwp_override
      @dwp_override ||= legal_aid_application.dwp_override || legal_aid_application.create_dwp_override!
    end
  end
end
