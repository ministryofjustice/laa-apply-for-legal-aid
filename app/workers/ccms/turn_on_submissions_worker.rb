module CCMS
  class TurnOnSubmissionsWorker
    include Sidekiq::Worker
    include Sidekiq::Status::Worker

    SUBMISSION_INTERVAL = 5

    def perform
      # get applications where state is submission_paused
      applications = LegalAidApplication.joins(:state_machine).where(state_machine_proxies: { aasm_state: "submission_paused" }).order(:merits_submitted_at)
      if applications.empty?
        Rails.logger.info "CCMS::RestartSubmissionsWorker - No paused submissions found"
      else
        Rails.logger.info "CCMS::RestartSubmissionsWorker - #{applications.size} submissions to restart, expected to take #{Time.zone.at(applications.size * SUBMISSION_INTERVAL).gmtime.strftime('%T')}"
        applications.each_with_index do |application, iteration|
          RestartSubmissionWorker.perform_in(iteration * SUBMISSION_INTERVAL, application.id)
        end
        Rails.logger.info "CCMS::RestartSubmissionsWorker - all submissions restarted"
      end
    end
  end
end
