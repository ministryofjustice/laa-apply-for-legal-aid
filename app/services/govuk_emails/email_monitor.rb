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

    def call # rubocop:disable Metrics/MethodLength
      if govuk_message_id.nil?
        send_first_email
      elsif email.permanently_failed?
        send_undeliverable_alert(:permanently_failed)
      elsif email.should_resend?
        send_new_email
      elsif !email.delivered?
        keep_monitoring
      end
    rescue Notifications::Client::NotFoundError => e
      # simulated_email_addresses can't be monitored
      unless simulated_email_address?
        send_undeliverable_alert(e)
        raise
      end
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

    def send_undeliverable_alert(error)
      failure_reason = if error.is_a?(StandardError)
                         error.class.to_s
                       else
                         error
                       end
      UndeliverableEmailAlertMailer.notify_apply_team(email_address, failure_reason, @mailer, @mail_method, @email_args)
    end

    def simulated_email_address?
      Rails.configuration.x.simulated_email_address.in?(email_args.to_s)
    end

    def email_address
      @email_args.detect { |arg| arg.to_s =~ /^\S+@\S+\.\S{2,3}$/ }
    end
  end
end
