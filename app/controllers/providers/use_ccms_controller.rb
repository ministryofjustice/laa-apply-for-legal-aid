module Providers
  class UseCCMSController < ProviderBaseController
    def show
      @legal_aid_application.use_ccms!(use_ccms_reason)
    end

    private

    def use_ccms_reason
      case request.referer
      when providers_legal_aid_application_open_banking_consents_url(@legal_aid_application)
        :no_online_banking
      else
        # debug logging to see where these 'unknown' ccms_reasons area coming from
        Raven.capture_message "Setting unknown CCMS reason, referer: #{request.referer}, not #{providers_legal_aid_application_open_banking_consents_url(@legal_aid_application)}"
        :unknown
      end
    end
  end
end
