require "rails_helper"

RSpec.describe ScheduledCCMSSubmissionsToggleJob do
  let(:job) { described_class.new }
  let(:setting) { Setting.setting }
  let(:slack_message_service) { instance_double(Slack::SendMessage) }

  before do
    allow(Slack::SendMessage).to receive(:call)
  end

  describe "#perform" do
    context "when ccms submissions are enabled" do
      before do
        setting.update!(enable_ccms_submission: true)
      end

      context "and the job is trying to turn them off" do
        it "disables ccms submissions" do
          expect { job.perform(:turn_off) }.to change { setting.reload.enable_ccms_submission }.from(true).to(false)
        end

        it "sends a Slack alert" do
          job.perform(:turn_off)
          expect(Slack::SendMessage).to have_received(:call).with(
            text: "CCMS submissions have been automatically turned *OFF*. They can be turned back on in the <http://www.example.com/admin/settings?locale=en|admin settings.>",
          )
        end
      end

      context "and the job is trying to turn them on" do
        it "does not change the ccms submissions setting" do
          expect { job.perform(:turn_on) }.not_to change { setting.reload.enable_ccms_submission }
        end

        it "sends a Slack alert" do
          job.perform(:turn_on)
          expect(Slack::SendMessage).to have_received(:call).with(
            text: "CCMS submissions are already turned *ON* so no action has been taken. They can be turned off in the <http://www.example.com/admin/settings?locale=en|admin settings.>",
          )
        end
      end

      context "and an alert is sent to turn on them on" do
        it "does not send a reminder" do
          job.perform(:alert)
          expect(Slack::SendMessage).not_to have_received(:call)
        end
      end
    end

    context "when ccms submissions are disabled" do
      before do
        setting.update!(enable_ccms_submission: false)
      end

      context "and the job is trying to turn them off" do
        it "does not change the ccms submissions setting" do
          expect { job.perform(:turn_off) }.not_to change { setting.reload.enable_ccms_submission }
        end

        it "sends a Slack alert" do
          job.perform(:turn_off)
          expect(Slack::SendMessage).to have_received(:call).with(
            text: "CCMS submissions are already turned *OFF* so no action has been taken. They can be turned on in the <http://www.example.com/admin/settings?locale=en|admin settings.>",
          )
        end
      end

      context "and the job is trying to turn them on" do
        it "enables ccms submissions" do
          expect { job.perform(:turn_on) }.to change { setting.reload.enable_ccms_submission }.from(false).to(true)
        end

        it "sends a Slack alert" do
          job.perform(:turn_on)
          expect(Slack::SendMessage).to have_received(:call).with(
            text: "CCMS submissions have been automatically turned *ON*. They can be turned back off in the <http://www.example.com/admin/settings?locale=en|admin settings.>",
          )
        end
      end

      context "and an alert is sent to turn on them on" do
        it "sends a reminder" do
          job.perform(:alert)
          expect(Slack::SendMessage).to have_received(:call).with(
            text: "REMINDER: Turn CCMS submissions back on in the <http://www.example.com/admin/settings?locale=en|admin settings>. If no action is taken, they will automatically be turned on at 08:00.",
          )
        end
      end
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
