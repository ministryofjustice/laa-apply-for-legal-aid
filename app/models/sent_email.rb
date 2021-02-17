class SentEmail < ApplicationRecord
  validates :mailer,
            :mail_method,
            :govuk_message_id,
            :sent_at, presence: true
end
