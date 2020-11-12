module Providers
  class UseCCMSEmployedController < ProviderBaseController
    def index
      @legal_aid_application.use_ccms!(:employed)
    end
  end
end
