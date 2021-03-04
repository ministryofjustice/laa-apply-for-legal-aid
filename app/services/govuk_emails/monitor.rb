module GovukEmails
  class Monitor
    def self.call(scheduled_mail_id)
      new(scheduled_mail_id).call
    end

    def initialize(scheduled_mail_id)
      @scheduled_mail = ScheduledMailing.find(scheduled_mail_id)
    end

    def call
      status = GovukEmails::Email.new(@scheduled_mail.govuk_message_id).status
      @scheduled_mail.update!(status: status)
      send_undeliverable_alerts if status.in?(ScheduledMailing::FAILURE_STATUSES)
    end

    private

    def send_undeliverable_alerts
      return unless HostEnv.production?

      Sentry.capture_message("Unable to deliver mail to #{@scheduled_mail.addressee} - ScheduledMailing record #{@scheduled_mail.id}")
      ScheduledMailing.send_now!(mailer_klass: UndeliverableEmailAlertMailer,
                                 mailer_method: :notify_apply_team,
                                 legal_aid_application_id: @scheduled_mail.legal_aid_application_id,
                                 addressee: Rails.configuration.x.support_email_address,
                                 arguments: [@scheduled_mail.id])
    end
  end
end
