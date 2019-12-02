module Admin
  class SubmittedApplicationsReportsController < ApplicationController
    before_action :authenticate_admin_user!
    layout 'admin'.freeze

    # GET /admin/submitted_applications_report
    def show
      @applications = submitted_applications
    end

    private

    def submitted_applications
      LegalAidApplication.submitted_applications
    end
  end
end
