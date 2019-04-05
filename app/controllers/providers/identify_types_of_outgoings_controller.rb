module Providers
  class IdentifyTypesOfOutgoingsController < ProviderBaseController
    def show
      authorize @legal_aid_application
    end
  end
end
