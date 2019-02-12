module Providers
  class ProvidersController < ProviderBaseController
    def show
      @provider = current_provider
    end
  end
end
