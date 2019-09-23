require 'rails_helper'

module CFE
  RSpec.describe CreateVehiclesService do
    let(:application) { create :legal_aid_application }
    let!(:vehicle) { create :vehicle, :populated }
    let(:submission) { create :cfe_submission, aasm_state: 'capitals_created', legal_aid_application: application }
    let(:expected_payload) { expected_payload_hash.to_json }
    let(:expected_response) { expected_response_hash.to_json }
    let(:cfe_host) { Rails.configuration.x.check_finanical_eligibility_host }
    let(:cfe_url) { "#{cfe_host}/assessments/#{submission.assessment_id}/vehicles" }

    before do
      allow(application).to receive(:applicant_receives_benefit?).and_return(true)
      allow(application).to receive(:calculation_date).and_return(Date.today)
      allow_any_instance_of(described_class).to receive(:request_body).and_return(expected_payload)
    end

    describe 'successful post' do
      before { stub_request(:post, cfe_url).with(body: expected_payload).to_return(body: expected_response) }

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
        expect(history.url).to eq cfe_url
        expect(history.http_method).to eq 'POST'
        expect(history.request_payload).to eq expected_payload
        expect(history.http_response_status).to eq 200
        expect(history.response_payload).to eq expected_response
        expect(history.error_message).to be_nil
      end
    end

    describe 'failed calls to CFE' do
      it_behaves_like 'a failed call to CFE'
    end

    def expected_payload_hash
      {
        vehicles: [
          {
            value: vehicle.estimated_value.to_s,
            loan_amount_outstanding: vehicle.payment_remaining.to_s,
            date_of_purchase: vehicle.purchased_on.strftime('%Y-%m-%d'),
            in_regular_use: vehicle.used_regularly
          }
        ]
      }
    end

    def expected_response_hash # rubocop:disable Metrics/MethodLength
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
      }
    end
  end
end
