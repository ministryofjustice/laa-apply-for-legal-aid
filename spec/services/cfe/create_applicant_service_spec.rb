require 'rails_helper'

module CFE # rubocop:disable Metrics/ModuleLength
  RSpec.describe CreateApplicantService do
    # uncomment this if you need to connect to a real instance of Check Financial Eligibility service
    # running on localhost
    #
    # before(:all) do
    #   VCR.configure { |c| c.ignore_hosts 'localhost' }
    # end
    #
    let(:application) { create :legal_aid_application, application_ref: 'L-XYZ-999' }
    let!(:applicant) { create :applicant, legal_aid_application: application, date_of_birth: Date.new(1999, 9, 11) }
    let(:submission) { create :cfe_submission, aasm_state: 'assessment_created', legal_aid_application: application }
    let(:faraday_connection) { double Faraday }
    let(:connection_param) { double.as_null_object }
    let(:expected_payload) do
      {
        applicant: {
          date_of_birth: '1999-09-11',
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
      expect(Faraday).to receive(:new).with(url: 'http://localhost:3001').and_return(faraday_connection)
      expect(faraday_connection).to receive(:post).and_yield(connection_param).and_return(faraday_response)
    end

    describe 'successful post' do
      let(:faraday_response) { double Faraday::Response, status: 200, body: expected_response }

      it 'calls with expected params and payload' do
        expect(connection_param).to receive(:url).with("/assessments/#{submission.assessment_id}/applicant")
        expect(connection_param).to receive(:headers)
        expect(connection_param).to receive(:body=).with(expected_payload)

        CreateApplicantService.call(submission)
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

    describe 'unsuccessful post' do
      context 'http status 422' do
        let(:faraday_response) { double Faraday::Response, status: 422, body: error_response }

        it 'raises an exception' do
          expect {
            CreateApplicantService.call(submission)
          }.to raise_error CFE::SubmissionError, 'Unprocessable entity'
        end

        it 'updates the submission record from initialised to failed' do
          expect(submission.submission_histories).to be_empty
          expect { CreateApplicantService.call(submission) }.to raise_error CFE::SubmissionError

          expect(submission.submission_histories.count).to eq 1
          history = submission.submission_histories.last
          expect(history.submission_id).to eq submission.id
          expect(history.url).to eq "http://localhost:3001/assessments/#{submission.assessment_id}/applicant"
          expect(history.http_method).to eq 'POST'
          expect(history.request_payload).to eq expected_payload
          expect(history.http_response_status).to eq 422
          expect(history.response_payload).to eq error_response
          expect(history.error_message).to be_nil
        end
      end

      context 'http status not 200 or 422' do
        let(:faraday_response) { double Faraday::Response, status: 503, body: error_response }

        it 'raises an exception' do
          expect {
            CreateApplicantService.call(submission)
          }.to raise_error CFE::SubmissionError, 'Unsuccessful HTTP response code'
        end

        it 'updates the submission record from initialised to failed' do
          expect(submission.submission_histories).to be_empty
          expect { CreateApplicantService.call(submission) }.to raise_error CFE::SubmissionError

          expect(submission.submission_histories.count).to eq 1
          history = submission.submission_histories.last
          expect(history.submission_id).to eq submission.id
          expect(history.url).to eq "http://localhost:3001/assessments/#{submission.assessment_id}/applicant"
          expect(history.http_method).to eq 'POST'
          expect(history.request_payload).to eq expected_payload
          expect(history.http_response_status).to eq 503
          expect(history.response_payload).to eq error_response
          expect(history.error_message).to be_nil
        end
      end

      def error_response
        {
          errors: ['Detailed error message'],
          success: false
        }.to_json
      end
    end
  end
end
