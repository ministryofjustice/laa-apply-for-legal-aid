require "rails_helper"
require Rails.root.join("spec/mock_objects/mock_queued_job")

RSpec.describe ScheduledMailingsDeliveryJob do
  subject(:perform) { described_class.new.perform }

  describe "ScheduledMailingsDeliveryJob" do
    let(:application) { create(:application, :with_everything) }
    let!(:mailing_one) { create(:scheduled_mailing, :due, legal_aid_application_id: application.id) }
    let!(:mailing_two) { create(:scheduled_mailing, :due_later) }

    describe "perform" do
      context "when calling DeliveryMan" do
        it "calls DeliveryMan for each due item" do
          expect(GovukEmails::DeliveryMan).to receive(:call).with(mailing_one.id)
          perform
        end
      end

      context "when rescheduling the next Delivery job" do
        let(:short_delay) { ScheduledMailingsDeliveryJob::DEFAULT_DELAY - 20.seconds }
        let(:early_job) { MockQueuedJob.new(described_class, short_delay.from_now) }

        before do
          allow(Sidekiq::ScheduledSet).to receive(:new).and_return(job_queue)
          allow(GovukEmails::DeliveryMan).to receive(:call)
        end

        context "when Delivery job is already scheduled for a few seconds from now" do
          let(:job_queue) { [early_job] }

          it "does not schedule another job" do
            expect(described_class).not_to receive(:set)
            perform
          end
        end

        context "when nothing is in the queue" do
          let(:job_queue) { [] }
          let(:job) { double "Sidekiq Job", perform_later: nil }
          let(:delay) { ScheduledMailingsDeliveryJob::DEFAULT_DELAY }

          it "schedules another delivery job" do
            expect(described_class).to receive(:set).with(wait: delay).and_return(job)
            perform
          end
        end
      end

      context "when scheduling the Monitoring job" do
        let(:short_delay) { EmailMonitorJob::DEFAULT_DELAY - 20.seconds }
        let(:early_job) { MockQueuedJob.new(EmailMonitorJob, short_delay.from_now) }

        before do
          allow(Sidekiq::ScheduledSet).to receive(:new).and_return(job_queue)
          allow(GovukEmails::DeliveryMan).to receive(:call)
        end

        context "when monitoring the job already scheduled for a few seconds from now" do
          let(:job_queue) { [early_job] }

          it "does not schedule another job" do
            expect(EmailMonitorJob).not_to receive(:perform_later)
            perform
          end
        end

        context "when nothing is in the queue" do
          let(:job_queue) { [] }

          it "starts a monitoring job" do
            expect(EmailMonitorJob).to receive(:perform_later)
            perform
          end
        end
      end

      context "when the database tables cannot be found" do
        before do
          allow(ScheduledMailing).to receive(:waiting).and_raise(ActiveRecord::StatementInvalid, 'PG::UndefinedTable: ERROR: relation "scheduled_mailings" does not exist')
        end

        it "raises a single error, rather than one per email" do
          expect(Sentry).to receive(:capture_message).with(/not available to send scheduled mailings/)
          perform
        end
      end
    end
  end
end
