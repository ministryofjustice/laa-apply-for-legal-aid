module Citizen
  class AccessToken < ApplicationRecord
    EXPIRES_AFTER_IN_DAYS = 8

    self.table_name = "citizen_access_tokens"

    belongs_to :legal_aid_application

    encrypts :token, deterministic: true

    validates :expires_on, comparison: { greater_than: ->(_record) { Date.current } }

    def self.generate_for(legal_aid_application:)
      create!(
        token: SecureRandom.uuid,
        expires_on: EXPIRES_AFTER_IN_DAYS.days.from_now,
        legal_aid_application:,
      )
    end
  end
end
