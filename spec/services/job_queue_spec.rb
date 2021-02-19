require 'rails_helper'
require Rails.root.join('spec/mock_objects/mock_queued_job')

RSpec.describe JobQueue do
  let(:long_delay) { EmailMonitorJob::DEFAULT_DELAY + 2.minutes }
  let(:short_delay) { EmailMonitorJob::DEFAULT_DELAY - 20.seconds }
  let(:late_job) { MockQueuedJob.new(EmailMonitorJob, long_delay.from_now) }
  let(:early_job) { MockQueuedJob.new(EmailMonitorJob, short_delay.from_now) }
  let(:other_job) { MockQueuedJob.new(ScheduledMailingsDeliveryJob, short_delay.from_now) }

  describe '.enqueued?' do
    before { allow(Sidekiq::ScheduledSet).to receive(:new).and_return(job_queue) }
    subject { described_class.enqueued?(EmailMonitorJob) }

    context 'empty queue' do
      let(:job_queue) { [] }
      it 'returns false' do
        expect(subject).to be false
      end
    end

    context 'job scheduled for later than the default delay time' do
      let(:job_queue) { [late_job] }
      it 'returns false' do
        expect(subject).to be false
      end
    end

    context 'job scheduled for before default delay' do
      let(:job_queue) { [early_job] }
      it 'returns true' do
        expect(subject).to be true
      end
    end

    context 'jobs scheduled for before and after the delay' do
      let(:job_queue) { [early_job, late_job] }
      it 'returns true' do
        expect(subject).to be true
      end
    end

    context 'other jobs in the queue' do
      let(:job_queue) { [other_job] }
      it 'returns false' do
        expect(subject).to be false
      end
    end
  end
end
