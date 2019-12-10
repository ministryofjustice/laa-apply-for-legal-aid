require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe SmokeTest::TestEmails do
  describe '.call', vcr: { cassette_name: 'smoke_test_emails' } do
    let(:all_mailers_files) { Dir["#{Rails.root.join('app/mailers')}/*.rb"].map { |file| File.basename(file, '.rb') } }
    let(:all_mailers) { all_mailers_files.map { |file| file.classify.constantize } - [ApplicationMailer] }

    subject { described_class.call }

    before do
      ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper.clear
      allow_any_instance_of(Notifications::Client).to receive(:get_notification).and_return(OpenStruct.new(status: 'delivered'))
      allow_any_instance_of(DashboardEventHandler).to receive(:call).and_return(double(DashboardEventHandler))
    end

    it 'tests all mailers' do
      all_mailers.each do |mailer|
        expect(mailer).to receive(:new).and_call_original
      end
      subject
      ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper.drain
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

    it 'sends a submission_confirmation email' do
      expect_any_instance_of(SubmissionConfirmationMailer).to receive(:notify).and_call_original
      subject
      ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper.drain
    end

    it 'sends a notify_provider email' do
      expect_any_instance_of(SubmitApplicationReminderMailer).to receive(:notify_provider).and_return(true)
      subject
      ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper.drain
    end
  end
end
