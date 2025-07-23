module OmniAuth
  module Strategies
    class EntraIdOidc < OmniAuth::Strategies::EntraId
      # we may only need the user_name attribute to query PDA for offices and firms
      # info { { user_name:, email:, roles:, office_codes: } }
      info { { user_name:, office_codes: } }

    private

      # The `LAA_ACCOUNTS` custom claim can be either a single office code (as a string)
      # or multiple office codes (as an array). Here we normalizes the value to always
      # return an array.
      #
      # NOTE: We may not need these regardless as we retrieve this data from Provider details API
      # (PDA) usually.
      #
      def office_codes
        [*user_info.raw_attributes.fetch("LAA_ACCOUNTS")]
      end

      # def email
      #   user_info.email
      # end

      # # This should be provided by custom "claim" in the EntraID response payload
      def user_name
        user_info.raw_attributes.fetch("USER_NAME", nil)
      end

      # Access to Civil Apply will be managed by LASSIE (a.k.a SILAS) and EntraID.
      # Setting roles as `ACCESS_CIVIL_APPLY` here until that is confirmed.
      # Once confirmed, `role` can be removed from providers althogether.
      # def roles
      #   %w[ACCESS_CIVIL_APPLY]
      # end

      class << self
        def mock_auth
          OmniAuth.config.test_mode = true

          OmniAuth.config.mock_auth[:entra_id] = OmniAuth::AuthHash.new({
            provider: "entra_id",
            uid: "mock-user-123",
            info: {
              name: "Mock Dev User",
              email: "martin.ronan@example.com",
            },
            credentials: {
              token: "mock_token_abc123",
              expires_at: Time.zone.now.to_i + 1.week,
            },
            extra: {
              raw_info: {
                oid: "mock-oid-entra",
                "USER_NAME" => "MARTIN.RONAN@DAVIDGRAY.CO.UK",
              },
            },
          })
        end
      end
    end
  end
end
