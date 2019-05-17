require 'rails_helper'

RSpec.describe CCMS::CheckApplicantStatusService do
  let(:submission) { create :submission, :applicant_submitted }
  let(:applicant_add_status_requestor) { double CCMS::ApplicantAddStatusRequestor }
  let(:history) { CCMS::SubmissionHistory.find_by(submission_id: submission.id) }
  let(:applicant_add_status_response) { ccms_data_from_file 'applicant_add_status_response.xml' }
  subject { described_class.new(submission) }

  before do
    allow(subject).to receive(:applicant_add_status_requestor).and_return(applicant_add_status_requestor)
  end

  context 'applicant_submitted state' do
    context 'operation successful' do
      let(:transaction_request_id_in_example_response) { '20190301030405123456' }

      context 'applicant not yet created' do
        before do
          expect(applicant_add_status_requestor).to receive(:call).and_return(applicant_add_status_response)
          expect(applicant_add_status_requestor).to receive(:transaction_request_id).and_return(transaction_request_id_in_example_response)
          allow_any_instance_of(CCMS::ApplicantAddStatusResponseParser).to receive(:success?).and_return(false)
        end

        context 'poll count remains below limit' do
          it 'increments the poll count' do
            expect { subject.call }.to change { submission.poll_count }.by 1
          end

          it 'does not change the state' do
            expect { subject.call }.not_to change { submission.aasm_state }
          end

          it 'writes a history record' do
            expect { subject.call }.to change { CCMS::SubmissionHistory.count }.by(1)
            expect(history.from_state).to eq 'applicant_submitted'
            expect(history.to_state).to eq 'applicant_submitted'
            expect(history.success).to be true
            expect(history.details).to be_nil
          end
        end

        context 'poll count reaches limit' do
          before do
            submission.poll_count = CCMS::Submission::POLL_LIMIT - 1
          end

          it 'increments the poll count' do
            expect { subject.call }.to change { submission.poll_count }.by 1
          end

          it 'changes the state to failed' do
            expect { subject.call }.to change { submission.aasm_state }.to 'failed'
          end

          it 'writes a history record' do
            expect { subject.call }.to change { CCMS::SubmissionHistory.count }.by(1)
            expect(history.from_state).to eq 'applicant_submitted'
            expect(history.to_state).to eq 'failed'
            expect(history.success).to be false
            expect(history.details).to eq 'Poll limit exceeded'
          end
        end
      end

      context 'applicant is created' do
        let(:expected_applicant_ccms_reference) { Faker::Number.number(10) }

        before do
          expect(applicant_add_status_requestor).to receive(:call).and_return(applicant_add_status_response)
          expect(applicant_add_status_requestor).to receive(:transaction_request_id).and_return(transaction_request_id_in_example_response)
          allow_any_instance_of(CCMS::ApplicantAddStatusResponseParser).to receive(:success?).and_return(true)
          allow_any_instance_of(CCMS::ApplicantAddStatusResponseParser).to receive(:applicant_ccms_reference).and_return(expected_applicant_ccms_reference)
        end

        it 'changes the state to applicant_ref_obtained' do
          expect { subject.call }.to change { submission.aasm_state }.to 'applicant_ref_obtained'
        end

        it 'updates the applicant_ccms_reference' do
          expect { subject.call }.to change { submission.applicant_ccms_reference }.to expected_applicant_ccms_reference
        end

        it 'writes a history record' do
          expect { subject.call }.to change { CCMS::SubmissionHistory.count }.by(1)
          expect(history.from_state).to eq 'applicant_submitted'
          expect(history.to_state).to eq 'applicant_ref_obtained'
          expect(history.success).to be true
          expect(history.details).to be_nil
        end

        it 'resets the poll count to 0' do
          subject.call
          expect(submission.poll_count).to eq 0
        end
      end
    end

    context 'operation unsuccessful' do
      let(:transaction_request_id_in_example_response) { '20190301030405123456' }

      before do
        expect(applicant_add_status_requestor).to receive(:call).and_raise(RuntimeError, 'oops')
        expect(applicant_add_status_requestor).to receive(:transaction_request_id).and_return(transaction_request_id_in_example_response)
      end

      it 'increments the poll count' do
        expect { subject.call }.to change { submission.poll_count }.by 1
      end

      it 'changes the state to failed' do
        expect { subject.call }.to change { submission.aasm_state }.to 'failed'
      end

      it 'records the error in the submission history' do
        expect { subject.call }.to change { CCMS::SubmissionHistory.count }.by(1)
        expect(history.from_state).to eq 'applicant_submitted'
        expect(history.to_state).to eq 'failed'
        expect(history.success).to be false
        expect(history.details).to match(/RuntimeError/)
        expect(history.details).to match(/oops/)
      end
    end
  end

  # private method tested here because it is mocked out above
  #
  describe '#applicant_add_status_requestor' do
    let(:service_double) { CCMS::CheckApplicantStatusService.new(submission) }
    let(:requestor1) { service_double.__send__(:applicant_add_status_requestor) }
    let(:requestor2) { service_double.__send__(:applicant_add_status_requestor) }
    it 'only instantiates one copy of the ApplicantAddStatusRequestor' do
      expect(requestor1).to be_instance_of(CCMS::ApplicantAddStatusRequestor)
      expect(requestor1.object_id).to eq requestor2.object_id
    end
  end
end
