module GovukEmails
  class Monitor
    attr_reader :scheduled_mail

    delegate :legal_aid_application, to: :scheduled_mail
    delegate :applicant, :provider, to: :legal_aid_application

    def self.call(scheduled_mail_id)
      new(scheduled_mail_id).call
    end

    def initialize(scheduled_mail_id)
      @scheduled_mail = ScheduledMailing.find(scheduled_mail_id)
    end

    def call
      scheduled_mail.update!(status: response.status)

      send_undeliverable_alerts if scheduled_mail.status.in?(ScheduledMailing::FAILURE_STATUSES)
    end

  private

    def response
      @response ||= GovukEmails::Email.new(scheduled_mail.govuk_message_id)
    end

    def send_undeliverable_alerts
      return unless HostEnv.production?

      AlertManager.capture_message("Unable to deliver mail to #{scheduled_mail.addressee} - ScheduledMailing record #{scheduled_mail.id}") unless citizen_start_email?

      send_undeliverable_alert_to_apply_team! unless citizen_start_email?
      send_undeliverable_citizen_start_email_to_provider!
    end

    def send_undeliverable_alert_to_apply_team!
      ScheduledMailing.send_now!(mailer_klass: UndeliverableEmailAlertMailer,
                                 mailer_method: :notify_apply_team,
                                 legal_aid_application_id: legal_aid_application.id,
                                 addressee: Rails.configuration.x.support_email_address,
                                 arguments: [scheduled_mail.id])
    end

    def send_undeliverable_citizen_start_email_to_provider!
      return unless scheduled_mail.mailer_method == "citizen_start_email" && scheduled_mail.status == "permanent-failure"

      ScheduledMailing.send_now!(mailer_klass: UndeliverableEmailAlertMailer,
                                 mailer_method: :notify_provider,
                                 legal_aid_application_id: legal_aid_application.id,
                                 addressee: provider_email_or_support,
                                 arguments: mailer_args)

      cancel_citizen_start_email_and_reminders!
    end

    def cancel_citizen_start_email_and_reminders!
      scheduled_mail.cancel!

      legal_aid_application
        .scheduled_mailings
        .where(mailer_klass: "SubmitCitizenFinancialReminderMailer")
        .where(mailer_method: "notify_citizen")
        .find_each(&:cancel!)
    end

    def mailer_args
      [
        provider.email,
        legal_aid_application.application_ref,
        applicant.full_name,
        applicant.email,
      ]
    end

    def provider_email_or_support
      HostEnv.staging? ? Rails.configuration.x.support_email_address : provider.email
    end

    def citizen_start_email?
      @scheduled_mail.mailer_method == "citizen_start_email"
    end
  end
end
