class ScheduledCCMSSubmissionsToggleJob < ApplicationJob
  include Sidekiq::Status::Worker

  def perform
    log "starting at #{Time.zone.now}"

    if Setting.enable_ccms_submission?
      turn_off_ccms_submissions
      alert_slack("CCMS submissions have been automatically turned *OFF*. They can be turned back on in the <#{admin_settings_url}|admin settings.>")
    else
      turn_on_ccms_submissions
      alert_slack("CCMS submissions have been automatically turned *ON*. They can be turned back off in the <#{admin_settings_url}|admin settings.>")
    end
  end

private

  def admin_settings_url
    Rails.application.routes.url_helpers.admin_settings_url
  end

  def turn_on_ccms_submissions
    Setting.setting.update!(enable_ccms_submission: true)
    CCMS::RestartSubmissions.call
  end

  def turn_off_ccms_submissions
    Setting.setting.update!(enable_ccms_submission: false)
  end

  def alert_slack(message)
    Slack::SendMessage.call(text: message)
  end

  def log(message)
    Rails.logger.info "ScheduledCCMSSubmissionsToggle :: #{message}"
  end
end
