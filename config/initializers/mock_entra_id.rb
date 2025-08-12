Rails.application.config.to_prepare do
  # rubocop:disable Rails/ActiveSupportOnLoad
  ActionDispatch::Request.prepend(Module.new do
    def path_info
      if super.start_with?("/auth/entra_id") && Setting.mock_entra_id?
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
              "LAA_ACCOUNTS" => %w[0X395U 2N078D A123456],
            },
          },
        })
      else
        OmniAuth.config.test_mode = false
      end

      super
    end
  end)
  # rubocop:enable Rails/ActiveSupportOnLoad
end
