module Providers
  class CheckClientDetailsController < ProviderBaseController
    def show
      applicant
      partner
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
  end
end
