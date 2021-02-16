class SentEmail < ApplicationRecord
  validates :mailer,
            :mail_method,
            :govuk_message_id,
            :addressee,
            :sent_at, presence: true
end
