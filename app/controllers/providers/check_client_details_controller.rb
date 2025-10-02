module Providers
  class CheckClientDetailsController < ProviderBaseController
    include DWPOutcomeHelper

    def show
      checking_dwp_status!(legal_aid_application)
      applicant
      partner

      force_dwp_required_details_check!
    end

    def update
      continue_or_draft
    end

  private

    def applicant
      @applicant ||= legal_aid_application.applicant || legal_aid_application.build_applicant
    end

    def partner
      @partner ||= legal_aid_application.partner || legal_aid_application.build_partner
    end

    def force_dwp_required_details_check!
      legal_aid_application.override_dwp_result! unless legal_aid_application.overriding_dwp_result?
    end
  end
end
