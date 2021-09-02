require 'rails_helper'

RSpec.describe SlackAlerter do
  before { allow(HostEnv).to receive(:environment).and_return(:uat) }

  let(:dummy_mail) { double ExceptionAlertMailer }

  describe '.capture_message' do
    let(:message) { 'dummy message' }
    let(:params) do
      {
        environment: 'uat',
        details: 'dummy message',
        to: SlackAlerter::SLACK_CHANNEL_EMAIL
      }
    end

    it 'delivers the email' do
      expect(ExceptionAlertMailer).to receive(:notify).with(params).and_return(dummy_mail)
      expect(dummy_mail).to receive(:deliver_now!)
      described_class.capture_message(message)
    end
  end

  describe '.capture_exception' do
    before do
      allow(exception).to receive(:backtrace).and_return("backtrace-line-1\n      backtrace-line-2")
    end

    let(:exception) { RuntimeError.new('my dummy error') }
    let(:formatted_message) do
      <<-END_OF_TEXT
      Exception raised: RuntimeError
      Message: my dummy error

      Backtrace:
      backtrace-line-1
      backtrace-line-2
      END_OF_TEXT
    end

    let(:params) do
      {
        environment: 'uat',
        details: formatted_message,
        to: SlackAlerter::SLACK_CHANNEL_EMAIL
      }
    end

    it 'delivers the mail' do
      expect(ExceptionAlertMailer).to receive(:notify).with(params).and_return(dummy_mail)
      expect(dummy_mail).to receive(:deliver_now!)
      described_class.capture_exception(exception)
    end
  end
end
