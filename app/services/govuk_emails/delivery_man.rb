module GovukEmails
  class DeliveryMan
    attr_reader :scheduled_mail

    delegate :arguments,
             :eligible_for_delivery?,
             :mailer_klass,
             :mailer_method, to: :scheduled_mail

    def self.call(scheduled_mail_id)
      new(scheduled_mail_id).call
    end

    def initialize(scheduled_mail_id)
      @scheduled_mail = ScheduledMailing.find(scheduled_mail_id)
    end

    def call
      return unless scheduled_mail.waiting? # in case another job has picked it up

      eligible_for_delivery? ? deliver_now : cancel!
    rescue StandardError => e
      Sentry.capture_exception(e)
    end

    private

    def deliver_now
      mail_message = mailer_klass.constantize.__send__(mailer_method, *arguments).deliver_now!
      @scheduled_mail.update!(status: 'processing',
                              govuk_message_id: mail_message.govuk_notify_response.id,
                              sent_at: Time.current)
    end

    def cancel!
      @scheduled_mail.cancel!
    end

    def eligible_for_delivery?
      mailer_klass.constantize.__send__(:eligible_for_delivery?, @scheduled_mail)
    end
  end
end
