module Citizens
  class DeclarationsController < BaseController
    include ApplicationFromSession
    before_action :authenticate_applicant!

    def show; end

    def update
      record_acceptance
      legal_aid_application.complete_means! unless legal_aid_application.means_completed?
      go_forward
    end

    private

    def record_acceptance
      return if legal_aid_application.declaration_accepted_at?

      legal_aid_application.update!(declaration_accepted_at: Time.now)
    end
  end
end
