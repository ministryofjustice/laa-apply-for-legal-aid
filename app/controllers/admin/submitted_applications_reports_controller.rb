module Admin
  class SubmittedApplicationsReportsController < ApplicationController
    include Pagy::Backend
    before_action :authenticate_admin_user!
    layout 'admin'.freeze

    DEFAULT_PAGE_SIZE = 10

    # GET /admin/submitted_applications_report
    def show
      @pagy, @applications = pagy(
        LegalAidApplication.submitted_applications,
        items: params.fetch(:page_size, DEFAULT_PAGE_SIZE),
        size: [1, 1, 1, 1]
      )
    end
  end
end
