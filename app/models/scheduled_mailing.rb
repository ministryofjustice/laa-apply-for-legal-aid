class ScheduledMailing < ApplicationRecord
  # records an email for immediate or later delivery. Use .send_now! or .send_later! methods to schedule mails.

  serialize :arguments, Array

  VALID_STATUSES = [
    'waiting', # record has been written, but mail not yet sent by ScheduledMailingsDeliveryJob
    'processing', # ScheduledMailingsDeliveryJob is in the process of sending the mail
    'created', # The mail has been sent to GOVUK Notify, but the status has not yet been queries
    'sending', # GOVUK Notify is still trying to send the mail
    'delivered', # GOVUK Notify has confirmed that the mail has been delivered
    'technical-failure', # GOVUK Notify has reported that the mail cannot  be sent due to a technical failure
    'permanent-failure', # GOVUK Notify has reported a permanent failure (most likely, non-existent email address)
    'temporary-failure', # GOVUK Notify has reported a temporary failure
    'cancelled' # Scheduled mail cancelled because it is no longer needed to be sent.
  ].freeze

  MONITORED_STATUSES = %w[processing created sending].freeze

  FAILURE_STATUSES = %w[technical-failure permanent-failure temporary-failure].freeze

  validates :status, inclusion: { in: VALID_STATUSES }
  validates :mailer_klass, :mailer_method, :addressee, :scheduled_at, presence: true

  belongs_to :legal_aid_application, optional: true

  scope :waiting, -> { where(status: 'waiting') }
  scope :past_due, -> { where('scheduled_at < ?', Time.current) }
  scope :monitored, -> { where(status: MONITORED_STATUSES) }

  def self.send_now!(mailer_klass:, mailer_method:, legal_aid_application_id:, addressee:, arguments:)
    create!(legal_aid_application_id: legal_aid_application_id,
            mailer_klass: mailer_klass,
            mailer_method: mailer_method,
            arguments: arguments,
            addressee: addressee,
            scheduled_at: Time.zone.now,
            status: 'waiting')
    ScheduledMailingsDeliveryJob.perform_later
  end

  def self.send_later!(mailer_klass:, mailer_method:, legal_aid_application_id:, addressee:, scheduled_at:, arguments:)
    create!(legal_aid_application_id: legal_aid_application_id,
            mailer_klass: mailer_klass,
            mailer_method: mailer_method,
            arguments: arguments,
            addressee: addressee,
            scheduled_at: scheduled_at,
            status: 'waiting')
  end

  def cancel!
    update!(cancelled_at: Time.current, status: 'cancelled')
  end

  def waiting?
    status == 'waiting'
  end
end
