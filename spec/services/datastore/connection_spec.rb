require "rails_helper"
require Rails.root.join("spec/services/datastore/data_access_api_stubs")

RSpec.describe Datastore::Connection do
  subject(:instance) { described_class.new(token_object: token_object) }

  let(:token_object) { build(:entra_id_token) }

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

    let(:uri) { "applications" }

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

    context "when access token scope is valid for datastore API already" do
      let(:token_object) { create(:entra_id_token, scope: Rails.configuration.x.data_access_api.auth_scope, access_token_expires_at: 1.hour.from_now) }

      before do
        stub_successful_datastore_submission
      end

      it "does not update the token object" do
        expect { post }.not_to change { token_object.reload.slice("id_token", "access_token", "access_token_expires_at", "refresh_token", "scope") }
      end
    end

    context "when access token scope does not include datastore API scope but is not expired" do
      let(:token_object) { create(:entra_id_token, scope: "fake_scope1 fake_scope2", access_token_expires_at: 1.hour.from_now) }

      before do
        stub_successful_datastore_submission
      end

      it "updates the token object with new, exchanged, token details" do
        expect { post }
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
            .from(a_value > Time.current)
            .to(a_value > Time.current)
      end
    end

    context "when access token has expired but includes datastore API scope" do
      let(:token_object) { create(:entra_id_token, access_token_expires_at: 1.minute.ago, scope: Rails.configuration.x.data_access_api.auth_scope) }

      before do
        stub_successful_datastore_submission
      end

      it "updates the token object with new, exchanged, token details" do
        expect { post }
          .to change { token_object.reload.slice("id_token", "access_token", "refresh_token", "scope") }
            .from(
              "id_token" => "fake_id_token",
              "access_token" => "fake_access_token",
              "refresh_token" => "fake_refresh_token",
              "scope" => Rails.configuration.x.data_access_api.auth_scope,
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
    end

    context "when access token expired and refresh token has expired" do
      let(:token_object) { build(:entra_id_token, access_token_expires_at: 1.hour.ago) }

      before do
        stub_expired_refresh_token_request
      end

      it "raises RefreshTokenExpired error" do
        expect { post }.to raise_error(Datastore::Connection::RefreshTokenExpired, "Failed to authenticate with datastore due to expired refresh token!")
      end

      it "logs info message about expired token" do
        allow(Rails.logger).to receive(:info)
        post
      rescue StandardError
        expect(Rails.logger).to have_received(:info).with("Refresh token expired. Provider will need to sign in again to get a new refresh token")
      end
    end

    context "when access token expired and token exchange fails due to other error" do
      let(:token_object) { build(:entra_id_token, access_token_expires_at: 1.hour.ago) }

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

    context "when an unexpected error occurs during token exchange" do
      let(:token_object) { build(:entra_id_token, scope: nil) }

      it "raises ConnectionError error with \"unexpected\" error details" do
        expect { post }.to raise_error(Datastore::Connection::ConnectionError, "Unexpected error occurred while authenticating with datastore: undefined method 'exclude?' for nil")
      end

      it "logs error message about \"unexpected\" error details" do
        allow(Rails.logger).to receive(:error)
        post
      rescue StandardError
        expect(Rails.logger).to have_received(:error).with("Unexpected error occurred while authenticating with datastore: undefined method 'exclude?' for nil")
      end
    end
  end
end
