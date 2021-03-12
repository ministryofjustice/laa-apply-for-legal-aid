module Providers
  class ReceivedBenefitConfirmationsController < ProviderBaseController
    def show
      @form = Providers::ReceivedBenefitConfirmationForm.new(model: dwp_override)
    end

    def update
      return continue_or_draft if draft_selected?

      @form = Providers::ReceivedBenefitConfirmationForm.new(form_params)

      if @form.valid?
        go_forward(form_params[:passporting_benefit] != 'none_selected')
      else
        render :show
      end
    end

    private

    def form_params
      merge_with_model(dwp_override) do
        params.require(:dwp_override).permit(:passporting_benefit)
      end
    end

    def dwp_override
      @dwp_override ||= legal_aid_application.dwp_override || legal_aid_application.create_dwp_override!
    end
  end
end
