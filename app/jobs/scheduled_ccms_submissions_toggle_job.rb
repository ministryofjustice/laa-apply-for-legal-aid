class ScheduledCCMSSubmissionsToggleJob < ApplicationJob
  include Sidekiq::Status::Worker

  def perform(input)
    log "starting at #{Time.zone.now}"

    case input
    when :turn_on
      Setting.enable_ccms_submission? ? ccms_submissions_already_on : turn_on_ccms_submissions
    when :turn_off
      Setting.enable_ccms_submission? ? turn_off_ccms_submissions : ccms_submissions_already_off
    when :alert
      reminder_turn_on_ccms_submissions unless Setting.enable_ccms_submission?
    end
  end

private

  def reminder_turn_on_ccms_submissions
    alert_slack("REMINDER: Turn CCMS submissions back on in the <#{admin_settings_url}|admin settings>. If no action is taken, they will automatically be turned on at 08:00.")
  end

  def admin_settings_url
    Rails.application.routes.url_helpers.admin_settings_url
  end

  def turn_on_ccms_submissions
    Setting.setting.update!(enable_ccms_submission: true)
    CCMS::TurnOnSubmissionsWorker.perform_async
    alert_slack("CCMS submissions have been automatically turned *ON*. They can be turned back off in the <#{admin_settings_url}|admin settings.>")
  end

  def turn_off_ccms_submissions
    Setting.setting.update!(enable_ccms_submission: false)
    alert_slack("CCMS submissions have been automatically turned *OFF*. They can be turned back on in the <#{admin_settings_url}|admin settings.>")
  end

  def ccms_submissions_already_on
    alert_slack("CCMS submissions are already turned *ON* so no action has been taken. They can be turned off in the <#{admin_settings_url}|admin settings.>")
  end

  def ccms_submissions_already_off
    alert_slack("CCMS submissions are already turned *OFF* so no action has been taken. They can be turned on in the <#{admin_settings_url}|admin settings.>")
  end

  def alert_slack(message)
    Slack::SendMessage.call(text: message)
  end

  def log(message)
    Rails.logger.info "ScheduledCCMSSubmissionsToggle :: #{message}"
  end
end
