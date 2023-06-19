module Providers
  module Partners
    class UseCCMSController < ProviderBaseController
      prefix_step_with :partner

      def index
        @legal_aid_application.use_ccms!(use_ccms_reason)
      end

    private

      def use_ccms_reason
        if @legal_aid_application.partner.armed_forces?
          :partner_armed_forces
        elsif @legal_aid_application.partner.self_employed?
          :partner_self_employed
        end
      end
    end
  end
end
