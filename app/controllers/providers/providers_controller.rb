module Providers
  class ProvidersController < ProviderBaseController
    legal_aid_application_not_required!
    use_custom_authorization!

    def show
      @provider = current_provider
    end
  end
end
