require "rails_helper"
require Rails.root.join("spec/services/datastore/data_access_api_stubs")

RSpec.describe Datastore::TokenService do
  describe ".call" do
    subject(:call) { described_class.new(token_object:).call }

    let(:token_object) { build(:entra_id_token, refresh_token: "fake_refresh_token", expires_at: 1.hour.from_now) }

    context "when token request is successful" do
      before do
        stub_successful_refresh_token_request
      end

      it "makes one external call" do
        call
        expect(a_request(:post, %r{https://login\.microsoftonline\.com/.*/oauth2/v2\.0/token})).to have_been_made.times(1)
      end

      it "updates the token object with the new refresh token and expires_in values" do
        # need to save token to check changes will be
        token_object.update!(expires_at: 1.minute.ago)

        expect { call }
          .to change { token_object.reload.refresh_token }
            .from("fake_refresh_token")
            .to("new_fake_refresh_token")
          .and change { token_object.reload.expires_at }
            .from(a_value < Time.current)
            .to(a_value > Time.current)
      end

      # NOTE: we could actually updated all tokens, and this might allow authcode or obo because
      # the new access_token has datastore api as its audience, and the id_token seems to have the Civil Apply
      # audience (for OBO). To be spiked.
      it "does NOT update token attributes unrelated to refreshing the token" do
        # need to save token to check changes will not be made
        token_object.save!

        expect { call }
          .not_to change { token_object.reload.slice("access_token", "id_token", "scope") }
            .from(
              "access_token" => "fake_access_token",
              "id_token" => "fake_id_token",
              "scope" => "fake_scope1 fake_scope2",
            )
      end

      it "returns a token response object" do
        object = call
        expect(object).to be_a(Datastore::TokenResponse)

        expect(object).to have_attributes(
          access_token: "new_fake_access_token",
          refresh_token: "new_fake_refresh_token",
          expires_in: 3600,
          id_token: "new_fake_id_token",
          scope: "new_fake_scope",
        )
      end
    end

    context "when token request fails due to expired refresh token" do
      before do
        stub_expired_refresh_token_request
      end

      it "raises error" do
        expect { call }.to raise_error(Datastore::TokenExchangeError, "Microsoft token exchange failed: invalid_grant: AADSTS999999: The refresh token has expired due to inactivity...")
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
