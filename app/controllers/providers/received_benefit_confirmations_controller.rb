module Providers
  class ReceivedBenefitConfirmationsController < ProviderBaseController
    def show
      @form = Providers::ReceivedBenefitConfirmationForm.new(model: dwp_override)
    end

    def update
      @form = Providers::ReceivedBenefitConfirmationForm.new(form_params)
      render :show unless save_continue_or_draft(@form)
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

# module Providers
#   class PolicyDisregardsController < ProviderBaseController
#     def show
#       @form = Providers::PolicyDisregardsForm.new(model: policy_disregards)
#     end

#     def update
#       @form = Providers::PolicyDisregardsForm.new(form_params)
#       render :show unless save_continue_or_draft(@form)
#     end

#     private

#     def policy_disregards
#       @policy_disregards ||= legal_aid_application.policy_disregards || legal_aid_application.create_policy_disregards!
#     end

#     def form_params
#       merge_with_model(policy_disregards) do
#         attrs = Providers::PolicyDisregardsForm::CHECK_BOXES_ATTRIBUTES
#         params[:policy_disregards].permit(*attrs)
#       end
#     end
#   end
# end
