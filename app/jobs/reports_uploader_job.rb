class ReportsUploaderJob < ApplicationJob
  include Sidekiq::Status::Worker
  def perform
    log "starting at #{Time.zone.now}"
    unless admin_report.application_details_report&.blob.nil?
      log "preexisting record as follows:"
      log "blob key: #{blob.key}, blob_id: #{blob.id}"
    end
    upload_application_details_report
    admin_report.save
    log "Application Details report attached as blob with key #{blob.key}, blob_id: #{blob.id}"
    log "AdminReport record updated at #{admin_report.updated_at}"
  end

  def expiration
    @expiration ||= 60 * 60 * 24 # Leave the status on the sidekiq output for 24 hours
  end

private

  def upload_application_details_report
    log "creating submitted applications report at #{Time.zone.now}"
    data = Reports::MIS::ApplicationDetailsReport.new.run
    log "application_details_report completed at #{Time.zone.now}"
    admin_report.application_details_report.attach io: StringIO.new(data),
                                                   filename: "application_details_report",
                                                   content_type: "text/csv"
  end

  def admin_report
    @admin_report ||= AdminReport.first || AdminReport.create!
  end

  def blob
    admin_report.application_details_report.blob
  end

  def log(message)
    Rails.logger.info "ReportsUploaderJob - #{message}"
  end
end
