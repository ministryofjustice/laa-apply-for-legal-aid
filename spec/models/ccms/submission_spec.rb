require 'rails_helper'

module CCMS # rubocop:disable Metrics/ModuleLength
  RSpec.describe Submission do
    let(:legal_aid_application) { create :legal_aid_application, :with_applicant }

    context 'Validations' do
      it 'errors if no legal aid application id is present' do
        sub = Submission.new
        expect(sub).not_to be_valid
        expect(sub.errors[:legal_aid_application_id]).to eq ["can't be blank"]
      end
    end

    describe 'initial state' do
      it 'puts new records into the initial state' do
        sub = Submission.create(legal_aid_application: legal_aid_application)
        expect(sub.aasm_state).to eq 'initialised'
      end
    end

    describe '#process' do
      context 'invalid state' do
        it 'raises if state is invalid' do
          sub = Submission.new(aasm_state: 'xxxxx')
          expect {
            sub.process!
          }.to raise_error RuntimeError, 'Unknown state'
        end
      end

      context 'initialised state' do
        let(:submission) { create :submission, :initialised, legal_aid_application: legal_aid_application }
        context 'operation successful' do
          let(:response) { File.read(File.join(Rails.root, 'spec', 'services', 'ccms', 'data', 'reference_data_response.xml')) }
          let(:requestor) { ReferenceDataRequestor.new }
          let(:transaction_request_id_in_example_response) { '20190301030405123456' }
          let(:ccms_case_ref_in_example_response) { '300000135140' }

          before do
            allow(submission).to receive(:reference_data_requestor).and_return(requestor)
            expect(requestor).to receive(:transaction_request_id).and_return(transaction_request_id_in_example_response)
            expect(requestor).to receive(:call).and_return(response)
          end

          it 'stores the reference number' do
            submission.process!
            expect(submission.case_ccms_reference).to eq ccms_case_ref_in_example_response
          end

          it 'changes the state to case_ref_obtained' do
            submission.process!
            expect(submission.aasm_state).to eq 'case_ref_obtained'
          end

          it 'writes a history record' do
            expect { submission.process! }.to change { SubmissionHistory.count }.by(1)
            history = SubmissionHistory.find_by(submission_id: submission.id)
            expect(history.from_state).to eq 'initialised'
            expect(history.to_state).to eq 'case_ref_obtained'
            expect(history.success).to be true
            expect(history.details).to be_nil
          end
        end

        context 'operation in error' do
          before do
            requestor_double = double ReferenceDataRequestor
            allow(requestor_double).to receive(:transaction_request_id).and_return('876876878')
            allow(submission).to receive(:reference_data_requestor).and_return(requestor_double)
            expect(requestor_double).to receive(:call).and_raise(RuntimeError, 'oops')
          end

          it 'puts it into failed state' do
            submission.process!
            expect(submission.aasm_state).to eq 'failed'
          end

          it 'records the error in the submission history' do
            expect { submission.process! }.to change { SubmissionHistory.count }.by(1)
            history = SubmissionHistory.find_by(submission_id: submission.id)
            expect(history.from_state).to eq 'initialised'
            expect(history.to_state).to eq 'failed'
            expect(history.success).to be false
            expect(history.details).to match(/RuntimeError/)
            expect(history.details).to match(/oops/)
          end
        end
      end

      context 'case_ref_obtained state' do
        let(:submission) { create :submission, :case_ref_obtained, legal_aid_application: legal_aid_application }

        context 'operation successful' do
          let(:applicant_search_requestor) { ApplicantSearchRequestor.new(legal_aid_application.applicant) }
          let(:applicant_add_requestor) { double ApplicantAddRequestor }
          let(:applicant_add_response_parser) { double ApplicantAddResponseParser }

          before do
            allow(submission).to receive(:applicant_search_requestor).and_return(applicant_search_requestor)
            expect(applicant_search_requestor).to receive(:call).and_return(applicant_search_response)
            expect(applicant_search_requestor).to receive(:transaction_request_id).and_return(transaction_request_id_in_example_response)
          end

          context 'no applicant exists on the CCMS system' do
            let(:applicant_search_response) { File.read(File.join(Rails.root, 'spec', 'services', 'ccms', 'data', 'applicant_search_response_no_results.xml')) }
            let(:applicant_add_response) { File.read(File.join(Rails.root, 'spec', 'services', 'ccms', 'data', 'applicant_add_response.xml')) }
            let(:transaction_request_id_in_example_response) { '20190301030405123456' }

            before do
              expect(ApplicantAddRequestor).to receive(:new).with(legal_aid_application.applicant).and_return(applicant_add_requestor)
              expect(applicant_add_requestor).to receive(:call).and_return(applicant_add_response)
              expect(applicant_add_requestor).to receive(:transaction_request_id).and_return(transaction_request_id_in_example_response)
              expect(ApplicantAddResponseParser).to receive(:new).and_return(applicant_add_response_parser)
              expect(applicant_add_response_parser).to receive(:parse).and_return('Success')
            end

            it 'sets state to applicant_submitted' do
              submission.process!
              expect(submission.aasm_state).to eq 'applicant_submitted'
            end

            it 'writes a history record' do
              expect { submission.process! }.to change { SubmissionHistory.count }.by(1)
              history = SubmissionHistory.find_by(submission_id: submission.id)
              expect(history.from_state).to eq 'case_ref_obtained'
              expect(history.to_state).to eq 'applicant_submitted'
              expect(history.success).to be true
              expect(history.details).to be_nil
            end
          end

          context 'applicant exists on the CCMS system' do
            let(:applicant_search_response_parser) { double ApplicantSearchResponseParser }
            let(:applicant_search_response) { File.read(File.join(Rails.root, 'spec', 'services', 'ccms', 'data', 'applicant_search_response_one_result.xml')) }
            let(:transaction_request_id_in_example_response) { '20190301030405123456' }
            let(:applicant_ccms_reference_in_example_response) { '1234567890' }

            before do
              expect(ApplicantSearchResponseParser).to receive(:new).and_return(applicant_search_response_parser)
              expect(applicant_search_response_parser).to receive(:parse).and_return(1)
              expect(applicant_search_response_parser).to receive(:applicant_ccms_reference).and_return(applicant_ccms_reference_in_example_response)
            end

            it 'updates the applicant_ccms_reference' do
              submission.process!
              expect(submission.applicant_ccms_reference).to eq applicant_ccms_reference_in_example_response
            end

            it 'sets the state to applicant_ref_obtained' do
              submission.process!
              expect(submission.aasm_state).to eq 'applicant_ref_obtained'
            end

            it 'writes a history record' do
              expect { submission.process! }.to change { SubmissionHistory.count }.by(1)
              history = SubmissionHistory.find_by(submission_id: submission.id)
              expect(history.from_state).to eq 'case_ref_obtained'
              expect(history.to_state).to eq 'applicant_ref_obtained'
              expect(history.success).to be true
              expect(history.details).to be_nil
            end
          end
        end

        context 'operation in error' do
          context 'error when searching for applicant' do
            before do
              requestor_double = double ApplicantSearchRequestor
              allow(requestor_double).to receive(:transaction_request_id).and_return('876876878')
              allow(submission).to receive(:applicant_search_requestor).and_return(requestor_double)
              expect(requestor_double).to receive(:call).and_raise(RuntimeError, 'oops when searching')
            end

            it 'puts it into failed state' do
              submission.process!
              expect(submission.aasm_state).to eq 'failed'
            end

            it 'records the error in the submission history' do
              expect { submission.process! }.to change { SubmissionHistory.count }.by(1)
              history = SubmissionHistory.find_by(submission_id: submission.id)
              expect(history.from_state).to eq 'case_ref_obtained'
              expect(history.to_state).to eq 'failed'
              expect(history.success).to be false
              expect(history.details).to match(/RuntimeError/)
              expect(history.details).to match(/oops when searching/)
            end
          end

          context 'error when adding an applicant' do
            let(:applicant_search_response) { File.read(File.join(Rails.root, 'spec', 'services', 'ccms', 'data', 'applicant_search_response_no_results.xml')) }
            let(:transaction_request_id_in_example_response) { '20190301030405123456' }
            before do
              applicant_search_requestor_double = double ApplicantSearchRequestor
              allow(submission).to receive(:applicant_search_requestor).and_return(applicant_search_requestor_double)
              expect(applicant_search_requestor_double).to receive(:call).and_return(applicant_search_response)
              expect(applicant_search_requestor_double).to receive(:transaction_request_id).and_return(transaction_request_id_in_example_response)
              applicant_add_requestor_double = double ApplicantAddRequestor
              allow(applicant_add_requestor_double).to receive(:transaction_request_id).and_return('876876878')
              allow(submission).to receive(:applicant_add_requestor).and_return(applicant_add_requestor_double)
              expect(applicant_add_requestor_double).to receive(:call).and_raise(RuntimeError, 'oops when adding')
            end

            it 'puts it into failed state' do
              submission.process!
              expect(submission.aasm_state).to eq 'failed'
            end

            it 'records the error in the submission history' do
              expect { submission.process! }.to change { SubmissionHistory.count }.by(1)
              history = SubmissionHistory.find_by(submission_id: submission.id)
              expect(history.from_state).to eq 'case_ref_obtained'
              expect(history.to_state).to eq 'failed'
              expect(history.success).to be false
              expect(history.details).to match(/RuntimeError/)
              expect(history.details).to match(/oops when adding/)
            end
          end

          context 'failed response from CCMS adding an applicant' do
            let(:applicant_search_response) { File.read(File.join(Rails.root, 'spec', 'services', 'ccms', 'data', 'applicant_search_response_no_results.xml')) }
            let(:applicant_add_response) { File.read(File.join(Rails.root, 'spec', 'services', 'ccms', 'data', 'applicant_add_response.xml')) }
            let(:transaction_request_id_in_example_response) { '20190301030405123456' }
            before do
              applicant_search_requestor = double ApplicantSearchRequestor
              allow(submission).to receive(:applicant_search_requestor).and_return(applicant_search_requestor)
              expect(applicant_search_requestor).to receive(:call).and_return(applicant_search_response)
              expect(applicant_search_requestor).to receive(:transaction_request_id).and_return(transaction_request_id_in_example_response)
              applicant_add_requestor = double ApplicantAddRequestor
              expect(ApplicantAddRequestor).to receive(:new).with(legal_aid_application.applicant).and_return(applicant_add_requestor)
              expect(applicant_add_requestor).to receive(:call).and_return(applicant_add_response)
              expect(applicant_add_requestor).to receive(:transaction_request_id).and_return(transaction_request_id_in_example_response)
              applicant_add_response_parser = double ApplicantAddResponseParser
              expect(ApplicantAddResponseParser).to receive(:new).and_return(applicant_add_response_parser)
              expect(applicant_add_response_parser).to receive(:parse).and_return('Failure')
            end

            it 'puts it into failed state' do
              submission.process!
              expect(submission.aasm_state).to eq 'failed'
            end

            it 'records the error in the submission history' do
              expect { submission.process! }.to change { SubmissionHistory.count }.by(1)
              history = SubmissionHistory.find_by(submission_id: submission.id)
              expect(history.from_state).to eq 'case_ref_obtained'
              expect(history.to_state).to eq 'failed'
              expect(history.success).to be false
              expect(history.details).to eq(applicant_add_response)
            end
          end
        end
      end
    end

    # private methods tested here because they are mocked out above
    #
    describe '#reference_data_requestor' do
      it 'only instantiates one copy of the ReferenceDataRequestor' do
        sub = Submission.new
        requestor1 = sub.__send__(:reference_data_requestor)
        requestor2 = sub.__send__(:reference_data_requestor)
        expect(requestor1).to be_instance_of(ReferenceDataRequestor)
        expect(requestor1.object_id).to eq requestor2.object_id
      end
    end

    describe '#applicant_search_requestor' do
      it 'only instantiates one copy of the ApplicantSearchRequestor' do
        sub = Submission.new(legal_aid_application: legal_aid_application)
        requestor1 = sub.__send__(:applicant_search_requestor)
        requestor2 = sub.__send__(:applicant_search_requestor)
        expect(requestor1).to be_instance_of(ApplicantSearchRequestor)
        expect(requestor1.object_id).to eq requestor2.object_id
      end
    end
  end
end
