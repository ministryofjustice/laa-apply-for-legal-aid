class ReportsUploaderJob < ApplicationJob
  # :nocov:
  def perform # rubocop:disable Metrics/AbcSize
    log "starting at #{Time.zone.now}"
    unless admin_report.application_details_report&.blob.nil?
      log 'preexisting record as follows:'
      log "blob key: #{blob.key}, blob_id: #{blob.id}"
    end
    upload_application_details_report
    admin_report.save
    log "Application Details report attached as blob with key #{blob.key}, blob_id: #{blob.id}"
    log "AdminReport record updated at #{admin_report.updated_at}"

    log_scheduled_sidekiq_jobs
  end

  private

  def upload_application_details_report
    log "creating submitted applications report at #{Time.zone.now}"
    data = Reports::MIS::ApplicationDetailsReport.new.run
    log "application_details_report completed at #{Time.zone.now}"
    admin_report.application_details_report.attach io: StringIO.new(data),
                                                   filename: 'application_details_report',
                                                   content_type: 'text/csv'
  end

  def admin_report
    @admin_report ||= AdminReport.first || AdminReport.create!
  end

  def blob
    admin_report.application_details_report.blob
  end

  def log_scheduled_sidekiq_jobs
    ss = Sidekiq::ScheduledSet.new
    log "Sidekiq Scheduled set size: #{ss.size}"
    ss.each { |job| log_job(job) }
  end

  def log(message)
    Rails.logger.info "ReportsUploaderJob - #{message}"
  end

  def log_job(job) # rubocop:disable Metrics/AbcSize
    log '>>>>>>>'
    log "    JID: #{job.jid}"
    log "    Queue: #{job.queue}"
    log "    Class: #{job.item['class']}"
    log "    Args: #{job.item['args']}"
    log "    Created: #{Time.zone.at(job.created_at)}"
    log "    Scheduled: #{Time.zone.at(job.score)}"
  end
  # :nocov:
end
