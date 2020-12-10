module Providers
  class UseCCMSController < ProviderBaseController
    def show
      @legal_aid_application.use_ccms!(use_ccms_reason) unless @legal_aid_application.use_ccms?
    end

    private

    def use_ccms_reason
      case request.referer
      when providers_legal_aid_application_open_banking_consents_url(@legal_aid_application)
        :no_online_banking
      else
        :unknown
      end
    end
  end
end
