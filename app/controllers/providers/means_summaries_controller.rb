module Providers
  class MeansSummariesController < ProviderBaseController
    def show
      authorize legal_aid_application
    end
  end
end
