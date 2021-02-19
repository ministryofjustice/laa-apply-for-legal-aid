require 'rails_helper'
require Rails.root.join('spec/mock_objects/mock_queued_job')

RSpec.describe ScheduledMailingsDeliveryJob do
  subject { described_class.new.perform }

  describe 'ScheduledMailingsDeliveryJob' do
    let(:application) { create :application, :with_everything }
    let!(:mailing_one) { create :scheduled_mailing, :due, legal_aid_application_id: application.id }
    let!(:mailing_two) { create :scheduled_mailing, :due_later }

    describe 'perform' do
      context 'calling DeliveryMan' do
        it 'calls DeliveryMan for each due item' do
          expect(GovukEmails::DeliveryMan).to receive(:call).with(mailing_one.id)
          subject
        end
      end

      context 'rescheduling the next Delivery job' do
        let(:short_delay) { ScheduledMailingsDeliveryJob::DEFAULT_DELAY - 20.seconds }
        let(:early_job) { MockQueuedJob.new(ScheduledMailingsDeliveryJob, short_delay.from_now) }

        before do
          allow(Sidekiq::ScheduledSet).to receive(:new).and_return(job_queue)
          allow(GovukEmails::DeliveryMan).to receive(:call)
        end

        context 'Delivery job already scheduled for a few seconds from now' do
          let(:job_queue) { [early_job] }
          it 'does not schedule another job' do
            expect(ScheduledMailingsDeliveryJob).not_to receive(:set)
            subject
          end
        end

        context 'nothing in the queue' do
          let(:job_queue) { [] }
          let(:job) { double 'Sidekiq Job', perform_later: nil }
          let(:delay) { ScheduledMailingsDeliveryJob::DEFAULT_DELAY }
          it 'schedules another delivery job' do
            expect(ScheduledMailingsDeliveryJob).to receive(:set).with(wait: delay).and_return(job)
            subject
          end
        end
      end

      context 'scheduling the Monitoring job' do
        let(:short_delay) { EmailMonitorJob::DEFAULT_DELAY - 20.seconds }
        let(:early_job) { MockQueuedJob.new(EmailMonitorJob, short_delay.from_now) }

        before do
          allow(Sidekiq::ScheduledSet).to receive(:new).and_return(job_queue)
          allow(GovukEmails::DeliveryMan).to receive(:call)
        end

        context 'monitoring job already scheduled for a few seconds from now' do
          let(:job_queue) { [early_job] }
          it 'does not schedule another job' do
            expect(EmailMonitorJob).not_to receive(:perform_later)
            subject
          end
        end

        context 'nothing in the queue' do
          let(:job_queue) { [] }
          it 'starts a montoring job' do
            expect(EmailMonitorJob).to receive(:perform_later)
            subject
          end
        end
      end
    end
  end
end
