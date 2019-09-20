require 'rails_helper'

module CFE
  RSpec.describe CreateApplicantService do
    context 'response received from CFE' do
      let(:application) { create :legal_aid_application, application_ref: 'L-XYZ-999' }
      let!(:applicant) { create :applicant, legal_aid_application: application, date_of_birth: Date.new(1999, 9, 11) }
      let(:submission) { create :cfe_submission, aasm_state: 'assessment_created', legal_aid_application: application }
      let(:expected_payload) do
        {
          applicant: {
            date_of_birth: applicant.date_of_birth.strftime('%Y-%m-%d'),
            involvement_type: 'applicant',
            has_partner_opponent: false,
            receives_qualifying_benefit: true
          }
        }.to_json
      end
      let(:expected_response) do
        {
          objects: [
            {
              id: 'b464458d-cf3d-4860-a1cc-a1838c2babd9',
              assessment_id: '3e1eb9db-f639-4fc2-81a7-0d12db4a2faf',
              date_of_birth: '1999-09-11',
              involvement_type: 'applicant',
              has_partner_opponent: false,
              receives_qualifying_benefit: true,
              created_at: '2019-09-11T14:15:58.641Z',
              updated_at: '2019-09-11T14:15:58.641Z'
            }
          ],
          errors: [],
          success: true
        }.to_json
      end

      before do
        allow(application).to receive(:applicant_receives_benefit?).and_return(true)
        allow(application).to receive(:calculation_date).and_return(Date.today)
      end

      describe 'successful post' do
        before do
          expect_any_instance_of(described_class).to receive(:request_body).exactly(2).times.and_return(expected_payload)
          stub_request(:post, "localhost:3001/assessments/#{submission.assessment_id}/applicant")
            .with(body: expected_payload)
            .to_return(body: expected_response)
        end

        it 'updates the submission record from assessment_created to applicant_created' do
          expect(submission.aasm_state).to eq 'assessment_created'
          CreateApplicantService.call(submission)
          expect(submission.aasm_state).to eq 'applicant_created'
        end

        it 'creates a submission_history record' do
          expect {
            CreateApplicantService.call(submission)
          }.to change { submission.submission_histories.count }.by 1
          history = CFE::SubmissionHistory.last
          expect(history.submission_id).to eq submission.id
          expect(history.url).to eq "http://localhost:3001/assessments/#{submission.assessment_id}/applicant"
          expect(history.http_method).to eq 'POST'
          expect(history.request_payload).to eq expected_payload
          expect(history.http_response_status).to eq 200
          expect(history.response_payload).to eq expected_response
          expect(history.error_message).to be_nil
        end
      end

      context 'unsuccessful_response_from_CFE' do
        describe 'failed calls to CFE' do
          it_behaves_like 'a failed call to CFE', CreateApplicantService, 'applicant'
        end
      end
    end

    context 'Faraday connection error' do
      let(:application) { create :legal_aid_application, application_ref: 'L-XYZ-999' }
      let!(:applicant) { create :applicant, legal_aid_application: application, date_of_birth: Date.new(1999, 9, 11) }
      let(:submission) { create :cfe_submission, aasm_state: 'assessment_created', legal_aid_application: application }

      it 'creates a CFE::SUbmission error and writes a history record with a backtrace' do
        stub_request(:post, "localhost:3001/assessments/#{submission.assessment_id}/applicant").to_raise(Faraday::ConnectionFailed.new('my faraday connection failed'))
        expect {
          CreateApplicantService.call(submission)
        }.to raise_error CFE::SubmissionError
        history = CFE::SubmissionHistory.last
        expect(history.submission_id).to eq submission.id
        expect(history.url).to eq "http://localhost:3001/assessments/#{submission.assessment_id}/applicant"
        expect(history.http_method).to eq 'POST'
        expect(history.http_response_status).to be_nil
        expect(history.response_payload).to be_nil
        expect(history.error_message).to eq 'CFE::CreateApplicantService received Faraday::ConnectionFailed: my faraday connection failed'
        expect(history.error_backtrace).not_to be_nil
      end
    end
  end
end
