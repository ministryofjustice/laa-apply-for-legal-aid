module Admin
  class SubmittedApplicationsReportsController < AdminBaseController
    include Pagy::Backend

    DEFAULT_PAGE_SIZE = 10

    # GET /admin/submitted_applications_report
    def show
      @pagy, @applications = pagy(
        LegalAidApplication.submitted_applications.includes(:ccms_submission).reorder("ccms_submissions.created_at DESC"),
        limit: params.fetch(:page_size, DEFAULT_PAGE_SIZE),
        size: 5,
      )
    end
  end
end
