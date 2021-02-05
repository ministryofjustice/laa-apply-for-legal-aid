FactoryBot.define do
  # rubocop:disable Style/NumericLiterals
  factory :hmrc_oauth_response, class: Hash do
    # access_token { "fake_bearer_token_#{[10, 50].sample}" }
    sequence(:access_token) { |n| "fake_bearer_token_#{n}" }
    scope { 'default' }
    expires_in { 14400 }
    token_type { 'bearer' }

    initialize_with { attributes }
  end
  # rubocop:enable Style/NumericLiterals
end
