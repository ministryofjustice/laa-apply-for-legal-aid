class ReportsUploaderJob < ApplicationJob
  # :nocov:
  def perform # rubocop:disable Metrics/AbcSize Layout/LineLength
    Rails.logger.info "ReportsUploaderJob - starting at #{Time.zone.now}"
    unless admin_report.submitted_applications&.blob.nil?
      Rails.logger.info 'ReportsUploaderJon - preexisting record as follows:'
      Rails.logger.info "ReportsUploaderJon - blob key: #{admin_report.submitted_applications.blob.key}, blob_id: #{admin_report.submitted_applications.blob.id}"
    end
    upload_submitted_applications
    upload_non_passported_applications
    admin_report.save
    # rubocop:disable Layout/LineLength
    Rails.logger.info "ReportsUploaderJob - Submitted applications report attached as blob with key #{admin_report.submitted_applications.blob.key}, blob_id: #{admin_report.submitted_applications.blob.id}"
    Rails.logger.info "ReportsUploaderJob - Non Passported applications report attached as blob with key: #{admin_report.non_passported_applications.blob.key}, blob_id: #{admin_report.non_passported_applications.blob.id}"
    Rails.logger.info "ReportsUploaderJob - AdminReport record updated at #{admin_report.updated_at}"
    # rubocop:enable Layout/LineLength

    log_scheduled_sidekiq_jobs
  end

  private

  def upload_submitted_applications
    Rails.logger.info "ReportsUploaderJob - creating submitted applications report at #{Time.zone.now}"
    data = Reports::MIS::ApplicationDetailsReport.new.run
    Rails.logger.info "ReportsUploaderJob - submitted applications report completed at #{Time.zone.now}"
    admin_report.submitted_applications.attach io: StringIO.new(data), filename: 'submitted_applications_report', content_type: 'text/csv'
  end

  def upload_non_passported_applications
    Rails.logger.info "ReportsUploaderJob - creating submitted applications report at #{Time.zone.now}"
    data = Reports::MIS::NonPassportedApplicationsReport.new.run
    Rails.logger.info "ReportsUploaderJob - submitted applications report completed at #{Time.zone.now}"
    admin_report.non_passported_applications.attach io: StringIO.new(data), filename: 'non_passported_applications_report', content_type: 'text/csv'
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
