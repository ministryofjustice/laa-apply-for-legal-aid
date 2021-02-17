module GovukEmails
  class EmailMonitor # rubocop:disable Metrics/ClassLength
    attr_reader :mailer, :mail_method, :delivery_method, :email_args
    attr_accessor :govuk_message_id

    JOBS_DELAY = 300.seconds

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
      else
        handle_status_check_response
      end
    end

    def handle_status_check_response
      update_sent_email

      if email.temp_or_perm_failed?
        send_undeliverable_alert(email.status)
        Raven.capture_message("Undeliverable Email Error - #{error_details.to_json}")
      elsif !email.delivered?
        keep_monitoring
      end
    rescue Notifications::Client::NotFoundError => e
      handle_not_found_exception(e)
    end

    def handle_not_found_exception(exception)
      return if simulated_email_address?

      send_undeliverable_alert(exception)
      update_sent_email_with_exception
      raise
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

    def error_details
      {
        mailer: @mailer,
        mail_method: @mail_method,
        delivery_method: @delivery_method,
        failure_reason: email.status,
        email_args: @email_args,
        govuk_message_id: @govuk_message_id
      }
    end

    def send_first_email
      self.govuk_message_id = send_email.govuk_notify_response.id
      create_sent_email
      keep_monitoring
    end

    def create_sent_email
      SentEmail.create!(mailer: @mailer,
                        mail_method: @mail_method,
                        addressee: email_address,
                        govuk_message_id: @govuk_message_id,
                        mailer_args: @email_args.to_json,
                        sent_at: Time.zone.now,
                        status: 'created',
                        status_checked_at: nil)
    rescue StandardError => e
      Raven.capture_message("Unable to write SentEmail record: #{e.class} #{e.message} Params: #{@email_args.inspect}")
    end

    def update_sent_email
      sent_email = SentEmail.find_by!(govuk_message_id: govuk_message_id)
      return unless sent_email # cater for cases where the sent email couldnt be created in the first place

      sent_email.update(status: email.status, status_checked_at: Time.zone.now)
    end

    def update_sent_email_with_exception
      sent_email = SentEmail.find_by!(govuk_message_id: govuk_message_id)
      sent_email.update(status: 'Notifications::Client::NotFoundError', status_checked_at: Time.zone.now)
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
      UndeliverableEmailAlertMailer.notify_apply_team(email_address, failure_reason, @mailer, @mail_method, @email_args).deliver_later!
    end

    def simulated_email_address?
      Rails.configuration.x.simulated_email_address.in?(email_args.to_s)
    end

    def email_address
      @email_args.detect { |arg| arg.to_s =~ /^\S+@\S+\.\S{2,3}$/ }
    end
  end
end
