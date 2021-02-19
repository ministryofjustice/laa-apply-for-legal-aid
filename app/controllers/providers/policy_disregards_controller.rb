module Providers
  class PolicyDisregardsController < ProviderBaseController
    def show
      @form = Providers::PolicyDisregardsForm.new(model: policy_disregards)
    end

    def update
      @form = Providers::PolicyDisregardsForm.new(form_params)
      render :show unless save_continue_or_draft(@form)
    end

    private

    def policy_disregards
      @policy_disregards ||= legal_aid_application.policy_disregards || legal_aid_application.create_policy_disregards!
    end

    def form_params
      merge_with_model(policy_disregards) do
        attrs = Providers::PolicyDisregardsForm::CHECK_BOXES_ATTRIBUTES
        params[:policy_disregards].permit(*attrs)
      end
    end
  end
end
