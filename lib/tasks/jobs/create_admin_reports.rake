namespace :job do
  namespace :admin_reports do
    desc "Upload admin reports"
    task upload: :environment do
      Rails.logger.info "rake job:admin_reports:upload queued at #{Time.zone.now}"
      ReportsUploaderJob.perform_now
    end
  end
end
