require "rails_helper"
require Rails.root.join("spec/services/datastore/data_access_api_stubs")

RSpec.describe Datastore::TokenExchangeService do
  describe ".call" do
    subject(:call) { described_class.new(token_object:).call }

    let(:token_object) { build(:entra_id_token, refresh_token: "fake_refresh_token", access_token_expires_at: 1.hour.from_now) }

    context "when token exchange is successful" do
      before do
        stub_successful_refresh_token_request
      end

      it "makes one external call" do
        call
        expect(a_request(:post, %r{https://login\.microsoftonline\.com/.*/oauth2/v2\.0/token})).to have_been_made.times(1)
      end

      it "updates the token object with the new values" do
        token_object.update!(access_token_expires_at: 1.minute.ago)

        expect { call }
          .to change { token_object.reload.slice("id_token", "access_token", "refresh_token", "scope") }
            .from(
              "id_token" => "fake_id_token",
              "access_token" => "fake_access_token",
              "refresh_token" => "fake_refresh_token",
              "scope" => "fake_scope1 fake_scope2",
            )
            .to(
              "id_token" => "new_fake_id_token",
              "access_token" => "new_fake_access_token",
              "refresh_token" => "new_fake_refresh_token",
              "scope" => Rails.configuration.x.data_access_api.auth_scope,
            )
          .and change { token_object.reload.access_token_expires_at }
            .from(a_value < Time.current)
            .to(a_value > Time.current)
      end

      it "returns a token response object" do
        object = call
        expect(object).to be_a(Datastore::TokenResponse)

        expect(object).to have_attributes(
          access_token: "new_fake_access_token",
          refresh_token: "new_fake_refresh_token",
          expires_in: 3666,
          id_token: "new_fake_id_token",
          scope: Rails.configuration.x.data_access_api.auth_scope,
        )
      end
    end

    context "when token request fails due to expired refresh token" do
      before do
        stub_expired_refresh_token_request
      end

      it "raises error" do
        expect { call }.to raise_error(Datastore::TokenExchangeError, "Microsoft token exchange failed: invalid_grant: AADSTS999999: The refresh token has expired...")
      end
    end

    context "when token request fails due to other error" do
      before do
        stub_other_failed_refresh_token_request
      end

      it "raises error" do
        expect { call }.to raise_error(Datastore::TokenExchangeError, "Microsoft token exchange failed: invalid_request: AADSTS999999: Something went wrong...")
      end
    end
  end
end
