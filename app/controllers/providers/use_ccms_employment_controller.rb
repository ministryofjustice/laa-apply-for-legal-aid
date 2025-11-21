module Providers
  class UseCCMSEmploymentController < ProviderBaseController
    def index
      @legal_aid_application.use_ccms!(use_ccms_reason)
    end

  private

    def use_ccms_reason
      if @legal_aid_application.applicant.self_employed?
        :applicant_self_employed
      elsif @legal_aid_application.applicant.armed_forces?
        :applicant_armed_forces
      end
    end
  end
end
