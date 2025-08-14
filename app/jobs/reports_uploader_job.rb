class ReportsUploaderJob < ApplicationJob
  include Sidekiq::Status::Worker

  def perform
    log "starting at #{Time.zone.now}"
    unless admin_report.application_details_report&.blob.nil?
      log "preexisting record as follows:"
      log "blob key: #{blob.key}, blob_id: #{blob.id}"
    end
    tempfile_name = attach_application_details_report
    admin_report.save!
    File.unlink(tempfile_name)
    log "Application Details report attached as blob with key #{blob.key}, blob_id: #{blob.id}"
    log "AdminReport record updated at #{admin_report.updated_at}"
  end

  def expiration
    @expiration ||= 60 * 60 * 24 # Leave the status on the sidekiq output for 24 hours
  end

private

  def attach_application_details_report
    log "creating submitted applications report at #{Time.zone.now}"
    tempfile_name = Reports::MIS::ApplicationDetailsReport.new.run
    log "application_details_report completed at #{Time.zone.now}"
    admin_report.application_details_report.attach io: File.open(tempfile_name),
                                                   filename: "application_details_report",
                                                   content_type: "text/csv"
    tempfile_name
  end

  def admin_report
    @admin_report ||= AdminReport.first || AdminReport.create!
  end

  def blob
    admin_report.application_details_report.blob
  end

  def log(message)
    Rails.logger.info "ReportsUploaderJob :: #{message}"
  end
end
