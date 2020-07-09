module GovukEmails
  class EmailMonitor
    attr_reader :mailer, :mail_method, :delivery_method, :email_args
    attr_accessor :govuk_message_id

    JOBS_DELAY = 5.seconds

    def self.call(**args)
      new(**args).call
    end

    def initialize(mailer:, mail_method:, delivery_method:, email_args:, govuk_message_id:)
      @mailer = mailer
      @mail_method = mail_method
      @delivery_method = delivery_method
      @email_args = email_args
      @govuk_message_id = govuk_message_id
    end

    def call
      if govuk_message_id.nil?
        send_first_email
      elsif email.permanently_failed?
        capture_error
      elsif email.should_resend?
        send_new_email
      elsif !email.delivered?
        keep_monitoring
      end
    rescue Notifications::Client::NotFoundError
      # smoke test emails can't be monitored
      raise unless smoke_test?
    end

    def trigger_job(message_id)
      args = message_id ? (email_args + [{ 'govuk_message_id' => message_id }]) : email_args
      GovukNotifyMailerJob.set(wait: JOBS_DELAY).perform_later(
        mailer,
        mail_method,
        delivery_method,
        args: args
      )
    end

    private

    def send_first_email
      self.govuk_message_id = send_email.govuk_notify_response.id
      keep_monitoring
    end

    def send_new_email
      trigger_job(nil)
    end

    def keep_monitoring
      trigger_job(govuk_message_id)
    end

    def email
      @email ||= Email.new(govuk_message_id)
    end

    def send_email
      mailer.constantize.public_send(mail_method, *email_args).send(delivery_method)
    end

    def capture_error
      raise StandardError, error_message
    rescue StandardError => e
      Raven.capture_exception(e)
    end

    def error_message
      [
        '*Email ERROR*',
        "*#{mailer}.#{mail_method}* could not be sent",
        "*GovUk email status:* #{email.status}",
        email_args.to_s
      ].join("\n")
    end

    def smoke_test?
      Rails.configuration.x.smoke_test_email_address.in?(email_args.to_s)
    end
  end
end
