module Providers
  class MeritsDeclarationsController < ProviderBaseController
    before_action :authorize_legal_aid_application

    def show; end

    def update
      legal_aid_application.complete_merits! unless draft_selected? || legal_aid_application.merits_completed?
      merits_assessment.update!(submitted_at: Time.current) unless merits_assessment.submitted_at?
      continue_or_draft
    end

    private

    def merits_assessment
      @merits_assessment ||= legal_aid_application.merits_assessment || legal_aid_application.build_merits_assessment
    end

    def authorize_legal_aid_application
      authorize @legal_aid_application
    end
  end
end
