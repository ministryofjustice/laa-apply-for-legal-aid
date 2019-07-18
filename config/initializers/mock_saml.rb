Rails.configuration.x.application.mock_saml = OpenStruct.new(
  usernames: [
    'really-really-long-email-address@example.com'.freeze,
    'test1@example.com'.freeze,
    'test2@example.com'.freeze,
    '1.office@example.com'.freeze
  ],
  password: 'password'.freeze
)
