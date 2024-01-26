require "rails_helper"

RSpec.describe Slack::SendMessage do
  subject(:slack_send_message) { described_class }

  before do
    allow(ENV).to receive(:fetch)
    allow(ENV).to receive(:fetch).with("SLACK_ALERT_WEBHOOK", nil).and_return(webhook_url)
    stub_request(:post, webhook_url).to_return(body: "OK", status: 200)
  end

  let(:message) { { text: "Hello, again, World!" } }
  let(:webhook_url) { "https://hooks.slack.com/services/F4KE/T0K3N/12345678" }

  describe ".call" do
    subject(:call) { slack_send_message.new(message).call }

    it "expect call to send a message" do
      call
      expect(WebMock).to have_requested(:post, webhook_url).once
    end
  end

  describe "#call" do
    subject(:call) { slack_send_message.call(message) }

    it "expect call to send a message" do
      call
      expect(WebMock).to have_requested(:post, webhook_url).once
    end

    describe "when no environment variable is set" do
      before { allow(ENV).to receive(:fetch).with("SLACK_ALERT_WEBHOOK", nil).and_return(nil) }

      it { expect { call }.to raise_error("No slack webhook found") }
    end
  end
end
