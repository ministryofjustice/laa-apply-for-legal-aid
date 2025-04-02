require "rails_helper"

RSpec.describe ScheduledCCMSSubmissionsToggleJob do
  let(:job) { described_class.new }
  let(:setting) { Setting.setting }
  let(:slack_message_service) { instance_double(Slack::SendMessage) }

  before do
    allow(Slack::SendMessage).to receive(:call)
  end

  context "when ccms submissions are enabled" do
    before do
      setting.update!(enable_ccms_submission: true)
    end

    it "disables ccms submissions" do
      expect { job.perform }.to change { setting.reload.enable_ccms_submission }.from(true).to(false)
    end

    it "sends a Slack alert" do
      job.perform
      expect(Slack::SendMessage).to have_received(:call).with(
        text: "CCMS submissions have been automatically turned *OFF*. They can be turned back on in the <http://www.example.com/admin/settings?locale=en|admin settings.>",
      )
    end
  end

  context "when ccms submissions are disabled" do
    before do
      setting.update(enable_ccms_submission: false)
    end

    it "enables ccms submissions" do
      expect { job.perform }.to change { setting.reload.enable_ccms_submission }.from(false).to(true)
    end

    it "sends a Slack alert" do
      job.perform
      expect(Slack::SendMessage).to have_received(:call).with(
        text: "CCMS submissions have been automatically turned *ON*. They can be turned back off in the <http://www.example.com/admin/settings?locale=en|admin settings.>",
      )
    end
  end

  describe "#alert_slack" do
    it "sends a Slack message with the correct text" do
      message = "Test Slack message"
      job.send(:alert_slack, message)
      expect(Slack::SendMessage).to have_received(:call).with(text: message)
    end
  end
end
