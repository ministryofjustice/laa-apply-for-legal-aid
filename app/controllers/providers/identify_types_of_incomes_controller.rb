module Providers
  class IdentifyTypesOfIncomesController < ProviderBaseController
    def show
      authorize @legal_aid_application
    end
  end
end
