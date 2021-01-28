module GovukEmails
  class Email
    attr_reader :id

    # states documentation:
    # https://docs.notifications.service.gov.uk/ruby.html#status-optional
    RESENDABLE_STATUS = %w[temporary-failure technical-failure].freeze
    PERMANENTLY_FAILED_STATUS = 'permanent-failure'.freeze
    DELIVERED_STATUS = 'delivered'.freeze

    def initialize(id)
      @id = id
    end

    def delivered?
      status == DELIVERED_STATUS
    end

    def should_resend?
      status.in?(RESENDABLE_STATUS)
    end

    def permanently_failed?
      status == PERMANENTLY_FAILED_STATUS
    end

    delegate :status, to: :email

    private

    def email
      @email ||= govuk_notify_client.get_notification(id)
    end

    def govuk_notify_client
      Notifications::Client.new(Rails.configuration.x.govuk_notify_api_key)
    end
  end
end
