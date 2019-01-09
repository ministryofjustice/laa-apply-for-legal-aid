module Providers
  class ProvidersController < BaseController
    def show
      @provider = current_provider
    end
  end
end
