require "rails_helper"

RSpec.describe CCMS::SubmissionProcessWorker do
  let(:state) { :initialised }
  let(:submission) { create(:submission, aasm_state: state) }
  let(:worker) { described_class.new }

  before do
    allow(CCMS::Submission).to receive(:find).with(submission.id).and_return(submission)
    allow(submission).to receive(:process!).and_return(true)
    worker.retry_count = 1
  end

  describe ".perform" do
    subject(:perform) { worker.perform(submission.id, state) }

    it "calls process! on the submission" do
      expect(submission).to receive(:process!)
      expect(described_class).to receive(:perform_async)
      perform
    end

    context "when the state changes to completed" do
      before do
        allow(submission).to receive_messages(aasm_state: :complete, completed?: true)
      end

      it "does not raise a new SubmissionProcessWorker job" do
        expect(described_class).not_to receive(:perform_async)
        perform
      end
    end

    context "when an error occurs" do
      context "when @retry_count is" do
        context "when below the halfway point" do
          before { worker.retry_count = 4 }

          it "does not raise a sentry error" do
            expect(Sentry).not_to receive(:capture_message)
            perform
          end

          context "when a not tracked error is raised" do
            before do
              # this should trigger state_unchanged? and therefore SubmissionStateUnchanged
              allow(submission).to receive(:aasm_state).and_return(state)
            end

            it do
              expect { perform }.to raise_error CCMS::SentryIgnoreThisSidekiqFailError
            end
          end
        end

        context "when at the halfway point" do
          before { worker.retry_count = 5 }

          it "does not raise a sentry error" do
            expect(Sentry).not_to receive(:capture_message)
            perform
          end

          context "when a not tracked error is raised" do
            before do
              # this should trigger state_unchanged? and therefore SubmissionStateUnchanged
              allow(submission).to receive(:aasm_state).and_return(state)
            end

            it do
              expect { perform }.to raise_error CCMS::SentryIgnoreThisSidekiqFailError
            end
          end
        end

        context "when one above the halfway point" do
          before { worker.retry_count = 6 }

          let(:expected_error) do
            <<~MESSAGE
              CCMS submission id: #{submission.id} is failing
              job stuck at state: #{submission.aasm_state} with retry count at #{worker.retry_count}
            MESSAGE
          end

          it "raises a sentry error" do
            expect(Sentry).to receive(:capture_message).with(expected_error)
            perform
          end

          context "when a not tracked error is raised" do
            before do
              # this should trigger state_unchanged? and therefore SubmissionStateUnchanged
              allow(submission).to receive(:aasm_state).and_return(state)
            end

            it do
              expect { perform }.to raise_error CCMS::SentryIgnoreThisSidekiqFailError
            end
          end
        end

        context "when above the halfway point" do
          before { worker.retry_count = 7 }

          it "does not raise a sentry error" do
            expect(Sentry).not_to receive(:capture_message)
            perform
          end

          context "when a not tracked error is raised" do
            before do
              # this should trigger state_unchanged? and therefore SubmissionStateUnchanged
              allow(submission).to receive(:aasm_state).and_return(state)
            end

            it do
              expect { perform }.to raise_error CCMS::SentryIgnoreThisSidekiqFailError
            end
          end
        end

        context "when at MAX_RETRIES" do
          before { worker.retry_count = 10 }

          let(:expected_error) do
            <<~MESSAGE
              CCMS submission id:  failed
              Moving CCMS::SubmissionProcessWorker to dead set, it failed with: /An error occurred
            MESSAGE
          end

          it "raises a sentry error" do
            described_class.within_sidekiq_retries_exhausted_block do
              expect(Sentry).to receive(:capture_message).with(expected_error)
            end
            perform
          end

          context "when a tracked error is raised" do
            before do
              # this should trigger state_unchanged? and therefore SubmissionStateUnchanged
              allow(submission).to receive(:aasm_state).and_return(state)
            end

            it do
              expect { perform }.to raise_error CCMS::SubmissionStateUnchanged
            end
          end
        end
      end
    end
  end
end
