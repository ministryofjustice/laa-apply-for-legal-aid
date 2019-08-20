module Providers
  class MeritsDeclarationsController < ProviderBaseController
    def show; end

    def update
      legal_aid_application.generate_merits_report! unless draft_selected? || !legal_aid_application.may_generate_merits_report?
      merits_assessment.update!(submitted_at: Time.current) unless merits_assessment.submitted_at?
      continue_or_draft
    end

    private

    def merits_assessment
      @merits_assessment ||= legal_aid_application.merits_assessment || legal_aid_application.build_merits_assessment
    end
  end
end
