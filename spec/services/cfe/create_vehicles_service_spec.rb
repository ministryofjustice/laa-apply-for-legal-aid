require 'rails_helper'

module CFE
  RSpec.describe CreateVehiclesService do
    let(:application) { create :legal_aid_application, application_ref: 'L-XYZ-999' }
    let!(:vehicle) do
      create :vehicle, legal_aid_application: application,
                       estimated_value: 8_250.0,
                       payment_remaining: 3_500.0,
                       purchased_on: Date.new(2019, 4, 1),
                       used_regularly: true
    end
    let(:submission) { create :cfe_submission, aasm_state: 'capitals_created', legal_aid_application: application }
    let(:faraday_connection) { double Faraday }
    let(:connection_param) { double.as_null_object }
    let(:expected_payload) do
      {
        vehicles: [
          {
            value: '8250.0',
            loan_amount_outstanding: '3500.0',
            date_of_purchase: '2019-04-01',
            in_regular_use: true
          }
        ]
      }.to_json
    end
    let(:expected_response) do
      {

        vehicles: [
          {
            id: 'bd60a11d-4cbe-4759-a46c-45c2866bee88',
            value: '8250.00',
            loan_amount_outstanding: '3500.00',
            date_of_purchase: '2019-04-01',
            in_regular_use: true,
            created_at: '2019-08-29T13:57:49.640Z',
            updated_at: '2019-08-29T13:57:49.640Z',
            capital_summary_id: '5b3a9100-2a01-4cd8-993d-5a6333c683cd',
            included_in_assessment: false,
            assessed_value: '0.0'
          }
        ],
        "errors": [],
        "success": true
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
        expect(connection_param).to receive(:url).with("/assessments/#{submission.assessment_id}/vehicles")
        expect(connection_param).to receive(:headers)
        expect(connection_param).to receive(:body=).with(expected_payload)

        CreateVehiclesService.call(submission)
      end

      it 'updates the submission record from assessment_created to applicant_created' do
        expect(submission.aasm_state).to eq 'capitals_created'
        CreateVehiclesService.call(submission)
        expect(submission.aasm_state).to eq 'vehicles_created'
      end

      it 'creates a submission_history record' do
        expect {
          CreateVehiclesService.call(submission)
        }.to change { submission.submission_histories.count }.by 1
        history = CFE::SubmissionHistory.last
        expect(history.submission_id).to eq submission.id
        expect(history.url).to eq "http://localhost:3001/assessments/#{submission.assessment_id}/vehicles"
        expect(history.http_method).to eq 'POST'
        expect(history.request_payload).to eq expected_payload
        expect(history.http_response_status).to eq 200
        expect(history.response_payload).to eq expected_response
        expect(history.error_message).to be_nil
      end
    end

    describe 'failed calls to CFE' do
      it_behaves_like 'a failed call to CFE', CreateVehiclesService, 'vehicles'
    end
  end
end
