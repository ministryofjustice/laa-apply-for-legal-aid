module OmniAuth
  module Strategies
    class EntraIdOidc < OmniAuth::Strategies::OpenIDConnect
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
          OmniAuth::AuthHash.new(
            provider: "entra_id",
            uid: "test-user",
            info: {
              email: "provider@example.com",
              roles: %w[ACCESS_CIVIL_APPLY],
              office_codes: %w[1A123B 2A555X 3B345C 4C567D],
            },
          )
        end
      end
    end
  end
end
