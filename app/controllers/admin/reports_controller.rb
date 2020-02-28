module Admin
  class ReportsController < ApplicationController
    include Pagy::Backend
    before_action :authenticate_admin_user!
    layout 'admin'.freeze

    DEFAULT_PAGE_SIZE = 10

    def index
      @reports = {
        csv_download: {
          report_title: 'Download CSV of all submitted applications',
          path: :admin_reports_submitted_csv_path,
          path_text: 'Download CSV'
        }
      }
    end

    def download_submitted
      respond_to do |format|
        format.csv do
          send_data Reports::MIS::ApplicationDetailsReport.new.run
        end
      end
    end
  end
end
