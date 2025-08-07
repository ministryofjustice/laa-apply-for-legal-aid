module Providers
  class InvalidSchedulesController < ProviderBaseController
    legal_aid_application_not_required!

    def show
      @provider = Provider.find(current_provider.id)
      session["signed_out"] = true
      session["feedback_return_path"] = destroy_provider_session_path
      sign_out current_provider
    end
  end
end
