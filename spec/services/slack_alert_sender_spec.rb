require 'rails_helper'

RSpec.describe SlackAlertSender do
  let(:message) { Faker::Lorem.paragraph }
  let(:webhook) { Faker::Lorem.characters }
  let(:slack_client) { Slack::Notifier.new(webhook) }

  before do
    allow(Rails.configuration.x).to receive(:slack_alerts_webhook).and_return(webhook)
    allow(Slack::Notifier).to receive(:new).with(webhook).and_return(slack_client)
  end

  subject { described_class.call(message) }

  describe '#call' do
    it 'sends the message to slack' do
      expect(slack_client).to receive(:ping).with(message)
      subject
    end

    context 'no webhook set' do
      let(:webhook) { '' }

      it 'does not send the message to slack' do
        expect(slack_client).not_to receive(:ping)
        subject
      end
    end
  end
end
