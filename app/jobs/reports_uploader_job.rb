class ReportsUploaderJob < ApplicationJob
  def perform
    upload_submitted_applications
    upload_non_passported_applications
    admin_report.save
  end

  private

  def upload_submitted_applications
    data = Reports::MIS::ApplicationDetailsReport.new.run
    admin_report.submitted_applications.attach io: StringIO.new(data), filename: 'submitted_applications_report', content_type: 'text/csv'
  end

  def upload_non_passported_applications
    data = Reports::MIS::NonPassportedApplicationsReport.new.run
    admin_report.non_passported_applications.attach io: StringIO.new(data), filename: 'non_passported_applications_report', content_type: 'text/csv'
  end

  def admin_report
    @admin_report ||= AdminReport.first || AdminReport.create!
  end
end
