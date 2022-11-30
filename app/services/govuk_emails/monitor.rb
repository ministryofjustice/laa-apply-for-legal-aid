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
      @scheduled_mail.update!(status:)
      send_undeliverable_alerts if status.in?(ScheduledMailing::FAILURE_STATUSES)
    end

  private

    def send_undeliverable_alerts
      return unless HostEnv.production?

      AlertManager.capture_message("Unable to deliver mail to #{@scheduled_mail.addressee} - ScheduledMailing record #{@scheduled_mail.id}")
      ScheduledMailing.send_now!(mailer_klass: UndeliverableEmailAlertMailer,
                                 mailer_method: :notify_apply_team,
                                 legal_aid_application_id: legal_aid_application.id,
                                 addressee: Rails.configuration.x.support_email_address,
                                 arguments: [@scheduled_mail.id])

      notify_provider_email_failed if @scheduled_mail.mailer_method == "citizen_start_email"
    end

    def notify_provider_email_failed
      ScheduledMailing.send_now!(mailer_klass: UndeliverableEmailAlertMailer,
                                 mailer_method: :notify_provider,
                                 legal_aid_application_id: legal_aid_application.id,
                                 addressee: provider_email_or_support,
                                 arguments: mailer_args)
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

    def legal_aid_application
      @legal_aid_application = @scheduled_mail.legal_aid_application
    end

    def applicant
      @applicant ||= legal_aid_application.applicant
    end

    def provider
      @provider ||= legal_aid_application.provider
    end
  end
end
