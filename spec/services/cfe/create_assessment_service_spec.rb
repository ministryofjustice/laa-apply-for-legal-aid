require 'rails_helper'

module CFE
  RSpec.describe CreateAssessmentService do
    # uncomment this if you need to connect to a real instance of Check Financial Eligibility service
    # running on localhost
    #
    # before(:all) do
    #   VCR.configure { |c| c.ignore_hosts 'localhost' }
    # end

    let(:application) { create :legal_aid_application, application_ref: 'L-XYZ-999' }
    let(:submission) { create :cfe_submission, aasm_state: 'initialised', legal_aid_application: application }
    let(:faraday_connection) { double Faraday }
    let(:connection_param) { double.as_null_object }
    let(:json_empty_string) { ''.to_json }
    let(:expected_payload) do
      {
        client_reference_id: 'L-XYZ-999',
        submission_date: Date.today. strftime('%Y-%m-%d'),
        matter_proceeding_type: 'domestic_abuse'
      }.to_json
    end
    let(:expected_response) do
      {
        success: true,
        objects: [
          {
            id: '1b2aa5eb-3763-445e-9407-2397ec3968f6',
            client_reference_id: 'L-XYZ-999',
            remote_ip: {
              family: 2,
              addr: 2_130_706_433,
              mask_addr: 4_294_967_295
            },
            created_at: '2019-09-11T14 =>15 =>58.672Z',
            updated_at: '2019-09-11T14 =>15 =>58.672Z',
            submission_date: '2019-06-06',
            matter_proceeding_type: 'domestic_abuse',
            assessment_result: 'pending'
          }
        ],
        errors: []
      }.to_json
    end

    before do
      allow(application).to receive(:calculation_date).and_return(Date.today)
      expect(Faraday).to receive(:new).with(url: 'http://localhost:3001').and_return(faraday_connection)
      expect(faraday_connection).to receive(:post).and_yield(connection_param).and_return(faraday_response)
    end

    describe 'successful post' do
      let(:faraday_response) { double Faraday::Response, status: 200, body: expected_response }

      it 'calls with expected params and payload' do
        expect(connection_param).to receive(:url).with('/assessments')
        expect(connection_param).to receive(:headers)
        expect(connection_param).to receive(:body=).with(expected_payload)

        CreateAssessmentService.call(submission)
      end

      it 'updates the submission record from initialised to assessment created' do
        expect(submission.aasm_state).to eq 'initialised'
        CreateAssessmentService.call(submission)
        expect(submission.aasm_state).to eq 'assessment_created'
      end

      it 'creates a submission_history record' do
        expect {
          CreateAssessmentService.call(submission)
        }.to change { submission.submission_histories.count }.by 1
        history = CFE::SubmissionHistory.last
        expect(history.submission_id).to eq submission.id
        expect(history.url).to eq 'http://localhost:3001/assessments'
        expect(history.http_method).to eq 'POST'
        expect(history.request_payload).to eq expected_payload
        expect(history.http_response_status).to eq 200
        expect(history.response_payload).to eq expected_response
        expect(history.error_message).to be_nil
      end
    end

    describe 'failed calls to CFE' do
      it_behaves_like 'a failed call to CFE', CreateAssessmentService, 'http://localhost:3001/assessments'
    end
  end
end
