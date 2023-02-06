module Providers
  class UseCCMSUnder16sController < ProviderBaseController
    def show
      @legal_aid_application.use_ccms!(:under_16_blocked) unless @legal_aid_application.use_ccms?
    end
  end
end
