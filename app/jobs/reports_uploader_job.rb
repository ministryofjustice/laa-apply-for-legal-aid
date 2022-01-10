class ReportsUploaderJob < ApplicationJob
  # :nocov:
  def perform # rubocop:disable Metrics/AbcSize Layout/LineLength
    Rails.logger.info "ReportsUploaderJob - starting at #{Time.zone.now}"
    unless admin_report.application_details_report&.blob.nil?
      Rails.logger.info 'ReportsUploaderJob - preexisting record as follows:'
      Rails.logger.info "ReportsUploaderJob - blob key: #{admin_report.application_details_report.blob.key}, blob_id: #{admin_report.application_details_report.blob.id}"
    end
    upload_application_details_report
    admin_report.save
    # rubocop:disable Layout/LineLength
    Rails.logger.info "ReportsUploaderJob - Application Details report attached as blob with key #{admin_report.application_details_report.blob.key}, blob_id: #{admin_report.application_details_report.blob.id}"
    Rails.logger.info "ReportsUploaderJob - AdminReport record updated at #{admin_report.updated_at}"
    # rubocop:enable Layout/LineLength

    log_scheduled_sidekiq_jobs
  end

  private

  def upload_application_details_report
    Rails.logger.info "ReportsUploaderJob - creating submitted applications report at #{Time.zone.now}"
    data = Reports::MIS::ApplicationDetailsReport.new.run
    Rails.logger.info "ReportsUploaderJob - application_details_report completed at #{Time.zone.now}"
    admin_report.application_details_report.attach io: StringIO.new(data), filename: 'application_details_report', content_type: 'text/csv'
  end

  def admin_report
    @admin_report ||= AdminReport.first || AdminReport.create!
  end

  def log_scheduled_sidekiq_jobs
    ss = Sidekiq::ScheduledSet.new
    Rails.logger.info "Sidekiq Scheduled set size: #{ss.size}"
    ss.each { |job| log_job(job) }
  end

  def log_job(job) # rubocop:disable Metrics/AbcSize
    Rails.logger.info '>>>>>>>'
    Rails.logger.info "    JID: #{job.jid}"
    Rails.logger.info "    Queue: #{job.queue}"
    Rails.logger.info "    Class: #{job.item['class']}"
    Rails.logger.info "    Args: #{job.item['args']}"
    Rails.logger.info "    Created: #{Time.zone.at(job.created_at)}"
    Rails.logger.info "    Scheduled: #{Time.zone.at(job.score)}"
  end
  # :nocov:
end
