module Providers
  class UseCCMSEmployedController < ProviderBaseController
    def index
      HMRC::CreateResponsesService.call(legal_aid_application)
      @legal_aid_application.use_ccms!(:employed)
    end
  end
end
