require "rails_helper"

module OmniAuth
  module HMRC
    RSpec.describe Client do
      subject(:client) { described_class.new }

      before do
        stub_request(:post, %r{(http|https).*laa-hmrc-interface.*\.cloud-platform\.service\.justice\.gov\.uk/oauth/token})
          .to_return(
            status: 200,
            body: '{"access_token":"test-bearer-token","token_type":"Bearer","expires_in":7200,"created_at":1582809000}',
            headers: { "Content-Type" => "application/json; charset=utf-8" },
          )
      end

      it { is_expected.to respond_to :oauth_client, :access_token, :bearer_token }

      describe "#oauth_client" do
        subject { described_class.new.oauth_client }

        it { is_expected.to be_an ::OAuth2::Client }
        it { is_expected.to respond_to :client_credentials }
      end

      describe "#access_token", :stub_oauth_token do
        subject(:access_token) { client.access_token }

        it { is_expected.to be_an ::OAuth2::AccessToken }
        it { is_expected.to respond_to :token }
        it { expect(access_token.token).to eql "test-bearer-token" }

        context "when token nil? or expired?" do
          before do
            allow(client).to receive(:new_access_token)
          end

          it "retrieves new access_token" do
            access_token
            expect(client).to have_received(:new_access_token)
          end
        end
      end

      describe "#bearer_token" do
        subject(:bearer_token) { client.bearer_token }

        context "when test_mode not set" do
          it "generates a new bearer_token" do
            expect(bearer_token).to eq "test-bearer-token"
          end
        end

        context "when test_mode is set" do
          before { allow(Rails.configuration.x.hmrc_interface).to receive(:test_mode?).and_return(true) }

          it "returns a set, fake, bearer_token" do
            expect(bearer_token).to eq "fake-hmrc-interface-bearer-token"
          end
        end
      end
    end
  end
end
