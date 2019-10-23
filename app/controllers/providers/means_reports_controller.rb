module Providers
  class MeansReportsController < ProviderBaseController
    authorize_with_policy :show_submitted_application?
    before_action :ensure_case_ccms_reference_exists

    def show
      render pdf: 'Means report',
             layout: 'pdf',
             show_as_html: params.key?(:debug)
    end

    private

    def ensure_case_ccms_reference_exists
      return if legal_aid_application.case_ccms_reference

      legal_aid_application.create_ccms_submission unless legal_aid_application.ccms_submission
      legal_aid_application.ccms_submission.process!
    end
  end
end
