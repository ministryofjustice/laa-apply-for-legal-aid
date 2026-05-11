FactoryBot.define do
  factory :entra_id_token do
    provider
    id_token { "fake_id_token" }
    access_token { "fake_access_token" }
    access_token_expires_at { 1.hour.from_now } # NOTE: this is randomized between 60 and 90 minutes by entra in reality, for load distribution
    refresh_token { "fake_refresh_token" }
    scope { "fake_scope1 fake_scope2" }
  end
end
