require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe SmokeTest::TestEmails do
  describe '.call', :vcr do
    subject { described_class.call }

    before do
      ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper.clear
      allow_any_instance_of(Notifications::Client).to receive(:get_notification).and_return(OpenStruct.new(status: 'delivered'))
    end

    it 'sends a feedback email' do
      expect_any_instance_of(FeedbackMailer).to receive(:notify).and_call_original
      subject
      ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper.drain
    end

    it 'sends a citizen_start_email email' do
      expect_any_instance_of(NotifyMailer).to receive(:citizen_start_email).and_call_original
      subject
      ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper.drain
    end

    it 'sends a resend_link_request email' do
      expect_any_instance_of(ResendLinkRequestMailer).to receive(:notify).and_call_original
      subject
      ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper.drain
    end
  end
end
