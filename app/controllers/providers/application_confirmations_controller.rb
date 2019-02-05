module Providers
  class ApplicationConfirmationsController < ProviderBaseController
    include ApplicationDependable
    include Flowable

    def show; end
  end
end
