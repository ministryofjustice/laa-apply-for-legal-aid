module OmniAuth
  module Strategies
    class AdminLogin < OmniAuth::Strategies::OpenIDConnect
      class << self
        def mock_auth
          OmniAuth.config.mock_auth[:entra_id] = OmniAuth::AuthHash.new({
            provider: :admin_entra_id,
            uid: "mock-admin-123",
            info: {
              name: "Mock Admin User",
              first_name: "Apply",
              last_name: "Maintenance",
              email: "apply-for-civil-legal-aid@justice.gov.uk",
            },
            credentials: {
              token: "mock_token_abc123",
              expires_at: Time.zone.now.to_i + 1.week,
            },
          })
        end
      end
    end
  end
end
