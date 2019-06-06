Rails.configuration.x.application.mock_saml = OpenStruct.new(
  usernames: [
    'test1@example.com'.freeze,
    'test2@example.com'.freeze,
    'really-really-long-email-address@example.com'.freeze
  ],
  password: 'password'.freeze
)
