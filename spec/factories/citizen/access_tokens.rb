module Citizen
  FactoryBot.define do
    factory :citizen_access_token, class: "Citizen::AccessToken" do
      legal_aid_application

      token { SecureRandom.uuid }
      expires_on { 8.days.from_now }
    end
  end
end
