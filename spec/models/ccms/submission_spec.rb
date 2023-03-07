require "rails_helper"
require "sidekiq/testing"

module CCMS
  RSpec.describe Submission do
    let(:state) { :initialised }
    let(:applicant_poll_count) { 0 }
    let(:case_poll_count) { 0 }
    let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_other_assets_declaration, :with_savings_amount, :submitting_assessment) }
    let(:submission) do
      create(:submission,
             legal_aid_application:,
             aasm_state: state,
             applicant_poll_count:,
             case_poll_count:)
    end

    context "with Validations" do
      it "errors if no legal aid application id is present" do
        submission.legal_aid_application = nil
        expect(submission).not_to be_valid
        expect(submission.errors[:legal_aid_application_id]).to eq ["can't be blank"]
      end
    end

    describe "initial state" do
      let(:submission) { create(:submission) }

      it "puts new records into the initial state" do
        expect(submission.aasm_state).to eq "initialised"
      end
    end

    describe "#process!" do
      let(:history) { SubmissionHistory.find_by(submission_id: submission.id) }

      context "with invalid state" do
        it "raises if state is invalid" do
          submission.aasm_state = "xxxxx"
          expect {
            submission.process!
          }.to raise_error CCMSError, "Submission #{submission.id} - Unknown state: xxxxx"
        end
      end

      context "with valid state" do
        let(:service) { CCMS::Submitters::ObtainCaseReferenceService }
        let(:service_instance) { service.new(submission) }

        before do
          allow(service).to receive(:new).with(submission).and_return(service_instance)
        end

        after { submission.process! }

        it "calls the obtain_case_reference service" do
          expect(service_instance).to receive(:call).with(no_args)
        end

        context "with case_ref_obtained state" do
          let(:state) { :case_ref_obtained }
          let(:service) { CCMS::Submitters::ObtainApplicantReferenceService }

          it "calls the obtain_applicant_reference service" do
            expect(service_instance).to receive(:call).with(no_args)
          end
        end

        context "with applicant_submitted state" do
          let(:state) { :applicant_submitted }
          let(:service) { CCMS::Submitters::CheckApplicantStatusService }

          it "calls the check_applicant_status service" do
            expect(service_instance).to receive(:call).with(no_args)
          end
        end

        context "with applicant_ref_obtained state" do
          let(:state) { :applicant_ref_obtained }
          let(:service) { CCMS::Submitters::ObtainDocumentIdService }

          it "calls the add_case service" do
            expect(service_instance).to receive(:call).with(no_args)
          end
        end

        context "with case_submitted state" do
          let(:state) { :case_submitted }
          let(:service) { CCMS::Submitters::CheckCaseStatusService }

          it "calls the check_case_status service" do
            expect(service_instance).to receive(:call).with(no_args)
          end
        end

        context "with case_created state" do
          let(:state) { :case_created }
          let(:service) { CCMS::Submitters::UploadDocumentsService }

          it "calls the obtain_document_id service" do
            expect(service_instance).to receive(:call).with(no_args)
          end
        end

        context "with document_ids_obtained state" do
          let(:state) { :document_ids_obtained }
          let(:service) { CCMS::Submitters::AddCaseService }

          it "calls the upload_documents service" do
            expect(service_instance).to receive(:call).with({})
          end
        end
      end
    end

    context "with state change:" do
      describe "#obtain_case_ref" do
        it "changes state" do
          expect { submission.obtain_case_ref }.to change(submission, :aasm_state).to("case_ref_obtained")
        end

        context "with event fail" do
          it "changes state" do
            expect { submission.fail }.to change(submission, :aasm_state).to("failed")
          end
        end

        context "with event complete" do
          let(:state) { :case_created }

          it "changes state" do
            expect { submission.complete }.to change(submission, :aasm_state).to("completed")
          end
        end
      end
    end

    describe "#process_async!" do
      context "when submission is in initialised state" do
        it "calls SubmissionProcessWorker with a delay of 5 seconds" do
          expect(SubmissionProcessWorker).to receive(:perform_async).with(submission.id, submission.aasm_state)
          submission.process_async!
        end
      end
    end

    describe "#sidekiq_running?" do
      subject(:sidekiq_running?) { submission.sidekiq_running? }

      context "when the submission.id is in the retry queue" do
        let(:sidekiq_entry) { instance_double Sidekiq::SortedEntry, args: [submission.id, "applicant_submitted"] }

        before do
          allow(Sidekiq::RetrySet).to receive(:new).and_return([sidekiq_entry])
        end

        it "returns :in_retry" do
          expect(sidekiq_running?).to eq :in_retry
        end
      end

      context "when the submission.id is currently running" do
        before do
          allow(Sidekiq::Workers).to receive(:new).and_return(["[\"FAKE:DATA:IDENTIFIER\", \"48ly\", {\"queue\"=>\"default\", \"payload\"=>{\"retry\"=>10, \"queue\"=>\"default\", \"args\"=>[\"#{submission.id}\", \"applicant_submitted\"], \"class\"=>\"CCMS::SubmissionProcessWorker\", \"jid\"=>\"97ead0dbe80ecb151b14ba46\", \"created_at\"=>1678181274.640068, \"enqueued_at\"=>1678196740.5113559, \"error_message\"=>\"Submission `#{submission.id}` failed at `applicant_submitted` on retry 9 with error CCMS::SubmissionStateUnchanged\", \"error_class\"=>\"CCMS::SentryIgnoreThisSidekiqFailError\", \"failed_at\"=>1678181277.234848, \"retry_count\"=>8, \"retried_at\"=>1678195277.342509}, \"run_at\"=>1678196740}]"])
        end

        it "returns :running" do
          expect(sidekiq_running?).to eq :running
        end
      end

      context "when the submission.id is not in any queue" do
        it "returns :false" do
          expect(sidekiq_running?).to be false
        end
      end
    end

    describe "#restart_existing_submission!" do
      it "is an alias of process_async!" do
        expect(submission.method(:restart_existing_submission!)).to eql(submission.method(:process_async!))
      end
    end

    describe "#complete_restart!" do
      subject(:complete_restart) { submission.complete_restart! }

      let(:state) { :document_ids_obtained }
      let(:applicant_poll_count) { 1 }
      let(:case_poll_count) { 1 }

      it "resets the values" do
        expect(submission).to receive(:process_async!).once
        expect { complete_restart }.to change(submission, :aasm_state).from("document_ids_obtained").to("initialised")
                                                                      .and(change(submission, :applicant_poll_count).from(1).to(0))
                                                                      .and(change(submission, :case_poll_count).from(1).to(0))
      end
    end
  end
end
