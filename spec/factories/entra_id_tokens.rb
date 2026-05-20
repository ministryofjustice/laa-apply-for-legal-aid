FactoryBot.define do
  factory :entra_id_token do
    provider
    id_token { "fake_id_token" }
    access_token { "fake_access_token" }
    refresh_token { "fake_refresh_token" }
    expires_at { 1.hour.from_now }
    scope { "fake_scope1 fake_scope2" }
  end
end
