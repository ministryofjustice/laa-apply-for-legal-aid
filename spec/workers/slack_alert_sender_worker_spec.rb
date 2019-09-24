require 'rails_helper'

RSpec.describe SlackAlertSenderWorker do
  let(:message) { Faker::Lorem.paragraph }

  subject { described_class.new.perform(message) }

  it 'sends the message to slack' do
    expect(SlackAlertSender).to receive(:call).with(message)
    subject
  end
end
