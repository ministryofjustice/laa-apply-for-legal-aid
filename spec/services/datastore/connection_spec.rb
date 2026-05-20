require "rails_helper"
require Rails.root.join("spec/services/datastore/data_access_api_stubs")

RSpec.describe Datastore::Connection do
  subject(:instance) { described_class.new(token_object: token_object) }

  let(:token_object) { build(:entra_id_token, refresh_token: "fake_refresh_token", expires_at: 1.hour.from_now) }

  describe "#initialize" do
    subject(:instance) { described_class.new(token_object: token_object) }

    before do
      stub_successful_refresh_token_request
    end

    it { is_expected.to have_attributes(token_object: token_object, connection: an_instance_of(Faraday::Connection)) }

    it { is_expected.to delegate_method(:post).to(:connection) }
  end

  describe "#post" do
    subject(:post) { instance.post(uri) }

    let(:uri) { "/" }

    context "when token exchange is successful" do
      before do
        stub_successful_refresh_token_request
      end

      it "delegated to adapter connection" do
        allow(instance.connection).to receive(:post)
        post
        expect(instance.connection).to have_received(:post)
      end
    end

    context "when token exchange fails due to expired refresh token" do
      let(:token_object) { build(:entra_id_token, refresh_token: "fake_refresh_token", expires_at: 1.hour.ago) }

      before do
        stub_expired_refresh_token_request
      end

      it "raises ConnectionExpired error" do
        expect { post }.to raise_error(Datastore::Connection::ConnectionExpired, "Failed to authenticate with datastore due to expired token!")
      end

      it "logs info message about expired token" do
        allow(Rails.logger).to receive(:info)
        post
      rescue StandardError
        expect(Rails.logger).to have_received(:info).with("Refresh token expired at #{token_object.expires_at}, you will need to sign in again to get a new refresh token")
      end
    end

    context "when token exchange fails due to other error" do
      before do
        stub_other_failed_refresh_token_request
      end

      it "raises ConnectionError error" do
        expect { post }.to raise_error(Datastore::Connection::ConnectionError, "Failed to authenticate with datastore: Microsoft token exchange failed: invalid_request: AADSTS999999: Something went wrong...")
      end

      it "logs error message about failed token exchange" do
        allow(Rails.logger).to receive(:error)
        post
      rescue StandardError
        expect(Rails.logger).to have_received(:error).with("Failed to exchange refresh token for datastore bearer token: Microsoft token exchange failed: invalid_request: AADSTS999999: Something went wrong...")
      end
    end
  end
end
