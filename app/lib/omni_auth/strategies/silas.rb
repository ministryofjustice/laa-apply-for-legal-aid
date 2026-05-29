module OmniAuth
  module Strategies
    class Silas < OmniAuth::Strategies::OpenIDConnect
      # we may only need the user_name attribute to query PDA for offices and firms
      # info { { user_name:, email:, roles:, office_codes: } }
      # info { { user_name:, office_codes: } }

      # private

      # The `LAA_ACCOUNTS` custom claim can be either a single office code (as a string)
      # or multiple office codes (as an array). Here we normalizes the value to always
      # return an array.
      #
      # NOTE: We may not need these regardless as we retrieve this data from Provider details API
      # (PDA) usually.
      #
      # TODO: Fix or remove. It is not usable currently
      # def office_codes
      #   [*user_info.raw_attributes.fetch("LAA_ACCOUNTS")]
      # end

      # def email
      #   user_info.email
      # end

      # # This should be provided by custom "claim" in the EntraID response payload
      # TODO: Fix or remove. It is not usable currently
      # def user_name
      #   user_info.raw_attributes.fetch("USER_NAME", nil)
      # end

      # Access to Civil Apply will be managed by LASSIE (a.k.a SILAS) and EntraID.
      # Setting roles as `ACCESS_CIVIL_APPLY` here until that is confirmed.
      # Once confirmed, `role` can be removed from providers althogether.
      # def roles
      #   %w[ACCESS_CIVIL_APPLY]
      # end

      class << self
        def mock_auth
          OmniAuth.config.mock_auth[:entra_id] = OmniAuth::AuthHash.new({
            provider: "entra_id",
            uid: "mock-user-123",
            info: {
              name: "Mock Dev User",
              first_name: "Martin",
              last_name: "Ronan",
              email: "martin.ronan@example.com",
            },
            credentials: {
              id_token: "mock_id_token_abc123",
              token: "mock_token_abc123",
              refresh_token: "mock_refresh_token_abc123",
              expires_in: rand(60..90).minutes.in_seconds, # mimics the token lifetime returned by EntraID, which is randomized between 60 and 90 minutes for load distribution
              scope: "mock_scope_abc123",
            },
            extra: {
              raw_info: {
                oid: "mock-oid-entra",
                "USER_NAME" => "51cdbbb4-75d2-48d0-aaac-fa67f013c50a",
                "LAA_ACCOUNTS" => %w[0X395U 2N078D A123456],
              },
            },
          })
        end
      end
    end
  end
end
