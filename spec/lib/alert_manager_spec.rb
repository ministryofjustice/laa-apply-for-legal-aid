require "rails_helper"

RSpec.describe AlertManager do
  before { Setting.setting.update(alert_via_sentry: sentry_setting) }

  let(:sample_sending_environment) { %i[production uat].sample }

  context "when setting is set to alert via Sentry" do
    let(:sentry_setting) { true }

    describe ".capture_exception" do
      let(:exception) { RuntimeError.new("my new error") }

      context "when in the production environment" do
        before { allow(HostEnv).to receive(:environment).and_return(sample_sending_environment) }

        it "delegates to Sentry" do
          expect(Sentry).to receive(:capture_exception).with(exception)
          described_class.capture_exception(exception)
        end

        it "does not send to Slack Alerter" do
          expect(SlackAlerter).not_to receive(:capture_exception).with(exception)
          described_class.capture_exception(exception)
        end
      end

      context "when in a non-production environment" do
        it "does not pass on to sentry" do
          expect(Sentry).not_to receive(:capture_exception)
          described_class.capture_exception(exception)
        end

        it "does not send to Slack Alerter" do
          expect(SlackAlerter).not_to receive(:capture_exception).with(exception)
          described_class.capture_exception(exception)
        end
      end
    end

    describe ".capture_message" do
      let(:message) { "This is my test message" }

      context "when in the production environment" do
        before { allow(HostEnv).to receive(:environment).and_return(sample_sending_environment) }

        it "delegates to Sentry" do
          expect(Sentry).to receive(:capture_message).with(message)
          described_class.capture_message(message)
        end

        it "does not send to Slack Alerter" do
          expect(SlackAlerter).not_to receive(:capture_message).with(message)
          described_class.capture_exception(message)
        end
      end

      context "when in a non-production environment" do
        it "does not pass on to sentry" do
          expect(Sentry).not_to receive(:capture_message)
          described_class.capture_exception(message)
        end

        it "does not send to Slack Alerter" do
          expect(SlackAlerter).not_to receive(:capture_message).with(message)
          described_class.capture_exception(message)
        end
      end
    end
  end

  context "when setting is set not to alert via Sentry" do
    let(:sentry_setting) { false }

    describe ".capture_exception" do
      let(:exception) { RuntimeError.new("my new error") }

      context "when in the production environment" do
        before { allow(HostEnv).to receive(:environment).and_return(sample_sending_environment) }

        it "delegates to SlackAlerter" do
          expect(SlackAlerter).to receive(:capture_exception).with(exception)
          described_class.capture_exception(exception)
        end

        it "does not send to Sentry" do
          expect(Sentry).not_to receive(:capture_exception).with(exception)
          allow(SlackAlerter).to receive(:capture_exception).with(exception)
          described_class.capture_exception(exception)
        end
      end

      context "when in a non-production environment" do
        it "does not pass on to SlackAlerter" do
          expect(SlackAlerter).not_to receive(:capture_exception)
          described_class.capture_exception(exception)
        end

        it "does not send to Sentry" do
          expect(Sentry).not_to receive(:capture_exception).with(exception)
          described_class.capture_exception(exception)
        end
      end
    end

    describe ".capture_message" do
      let(:message) { "This is my test message" }

      context "when in a production environment" do
        before { allow(HostEnv).to receive(:environment).and_return(sample_sending_environment) }

        it "delegates to SlackAlerter" do
          expect(SlackAlerter).to receive(:capture_message).with(message)
          described_class.capture_message(message)
        end

        it "does not send to Sentry" do
          expect(Sentry).not_to receive(:capture_message).with(message)
          allow(SlackAlerter).to receive(:capture_message)
          described_class.capture_message(message)
        end
      end

      context "when in a non-production environment" do
        it "does not pass on to sentry" do
          expect(Sentry).not_to receive(:capture_message)
          described_class.capture_message(message)
        end

        it "does not send to Slack Alerter" do
          expect(SlackAlerter).not_to receive(:capture_message).with(message)
          described_class.capture_message(message)
        end
      end
    end
  end
end
