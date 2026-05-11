require "rails_helper"
require Rails.root.join("spec/services/datastore/data_access_api_stubs")

RSpec.describe Datastore::TokenService do
  describe ".call" do
    subject(:call) { described_class.new(refresh_token: "fake_refresh_token").call }

    context "with successful bearer token exchange response" do
      before do
        stub_successful_refresh_token_request
      end

      it "makes one external call" do
        call
        expect(a_request(:post, %r{https://login\.microsoftonline\.com/.*/oauth2/v2\.0/token})).to have_been_made.times(1)
      end

      it "returns a token response object" do
        object = call
        expect(object).to be_a(Datastore::TokenResponse)

        expect(object).to have_attributes(
          access_token: "fake_access_token",
          refresh_token: "fake_refresh_token",
          expires_in: 3600,
          id_token: "fake_id_token",
          scope: "fake_scope",
        )
      end
    end

    context "with unsuccessful token request response" do
      before do
        stub_failed_refresh_token_request
      end

      it "raises error" do
        expect { call }.to raise_error(Datastore::TokenExchangeError, "Microsoft token exchange failed: invalid_grant: AADSTS999999: The refresh token has expired due to inactivity...")
      end
    end
  end
end
