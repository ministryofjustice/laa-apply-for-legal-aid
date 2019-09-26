require 'rails_helper'

RSpec.describe CCMS::CheckApplicantStatusService do
  let(:submission) { create :submission, :applicant_submitted }
  let(:applicant_add_status_requestor) { double CCMS::ApplicantAddStatusRequestor }
  let(:history) { CCMS::SubmissionHistory.find_by(submission_id: submission.id) }
  let(:applicant_add_status_response) { ccms_data_from_file 'applicant_add_status_response.xml' }
  let(:applicant_add_status_request) { ccms_data_from_file 'applicant_add_status_request.xml' }
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
          allow(applicant_add_status_requestor).to receive(:formatted_xml).and_return(applicant_add_status_request)
          allow_any_instance_of(CCMS::ApplicantAddStatusResponseParser).to receive(:success?).and_return(false)
        end

        context 'poll count remains below limit' do
          it 'increments the poll count' do
            expect { subject.call }.to change { submission.applicant_poll_count }.by 1
          end

          it 'does not change the state' do
            expect { subject.call }.not_to change { submission.aasm_state }
          end

          it 'writes a history record' do
            expect { subject.call }.to change { CCMS::SubmissionHistory.count }.by(1)
            expect(history.from_state).to eq 'applicant_submitted'
            expect(history.to_state).to eq 'applicant_submitted'
            expect("<?xml version=\'1.0\' encoding=\'UTF-8\'?>\n"+history.request).to eq applicant_add_status_request
            expect(history.request).to_not be_nil
            expect(history.success).to be true
            expect(history.details).to be_nil
          end
        end

        context 'poll count reaches limit' do
          before do
            submission.applicant_poll_count = CCMS::Submission::POLL_LIMIT - 1
          end

          it 'increments the poll count' do
            expect { subject.call }.to change { submission.applicant_poll_count }.by 1
          end

          it 'changes the state to failed' do
            expect { subject.call }.to change { submission.aasm_state }.to 'failed'
          end

          it 'writes a history record' do
            expect { subject.call }.to change { CCMS::SubmissionHistory.count }.by(1)
            expect(history.from_state).to eq 'applicant_submitted'
            expect(history.to_state).to eq 'failed'
            expect("<?xml version=\'1.0\' encoding=\'UTF-8\'?>\n"+history.request).to eq applicant_add_status_request
            expect(history.request).to_not be_nil
            expect(history.success).to be false
            expect(history.details).to eq 'Poll limit exceeded'
          end
        end
      end

      context 'applicant is created' do
        let(:expected_applicant_ccms_reference) { Faker::Number.number.to_s }

        before do
          expect(applicant_add_status_requestor).to receive(:call).and_return(applicant_add_status_response)
          allow(applicant_add_status_requestor).to receive(:formatted_xml).and_return(applicant_add_status_request)
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
          expect("<?xml version=\'1.0\' encoding=\'UTF-8\'?>\n"+history.request).to eq applicant_add_status_request
          expect(history.request).to_not be_nil
          expect(history.success).to be true
          expect(history.details).to be_nil
        end
      end
    end

    context 'operation unsuccessful' do
      let(:transaction_request_id_in_example_response) { '20190301030405123456' }

      before do
        expect(applicant_add_status_requestor).to receive(:call).and_raise(CCMS::CcmsError, 'oops')
        allow(applicant_add_status_requestor).to receive(:formatted_xml).and_return(applicant_add_status_request)
        expect(applicant_add_status_requestor).to receive(:transaction_request_id).and_return(transaction_request_id_in_example_response)
      end

      it 'increments the poll count' do
        expect { subject.call }.to change { submission.applicant_poll_count }.by 1
      end

      it 'changes the state to failed' do
        expect { subject.call }.to change { submission.aasm_state }.to 'failed'
      end

      it 'records the error in the submission history' do
        expect { subject.call }.to change { CCMS::SubmissionHistory.count }.by(1)
        expect(history.from_state).to eq 'applicant_submitted'
        expect(history.to_state).to eq 'failed'
        expect("<?xml version=\'1.0\' encoding=\'UTF-8\'?>\n"+history.request).to eq applicant_add_status_request
        expect(history.request).to_not be_nil
        expect(history.success).to be false
        expect(history.details).to match(/CCMS::CcmsError/)
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
      expect(requestor1).to eq requestor2
    end
  end
end
