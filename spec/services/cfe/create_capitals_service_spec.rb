require 'rails_helper'

module CFE # rubocop:disable Metrics/ModuleLength
  RSpec.describe CreateCapitalsService do
    describe '.call' do
      let(:connection_param) { double.as_null_object }
      let(:faraday_connection) { double Faraday }
      let(:application) { create :legal_aid_application }
      let!(:other_assets_declaration) do
        create :other_assets_declaration,
               legal_aid_application: application,
               timeshare_property_value: 256_000.0,
               land_value: 100_000.0,
               valuable_items_value: 32_500.0,
               inherited_assets_value: nil,
               money_owed_value: 0.0,
               trust_value: 99_999.99
      end
      let!(:savings_amount) do
        create :savings_amount,
               legal_aid_application: application,
               isa: 333.33,
               cash: 25.00,
               other_person_account: 100.0,
               national_savings: 750.0,
               plc_shares: nil,
               peps_unit_trusts_capital_bonds_gov_stocks: 0.0,
               life_assurance_endowment_policy: nil
      end
      let(:submission) { create :cfe_submission, aasm_state: 'applicant_created', legal_aid_application: application }
      let(:expected_payload) do
        {
          'bank_accounts' => [
            {
              description: 'Off-line bank accounts',
              value: '333.33'
            },
            {
              description: 'Cash',
              value: '25.0'
            },
            {
              description: "Signatory on other person's account",
              value: '100.0'
            },
            {
              description: 'National savings',
              value: '750.0'
            },
          ],
          'non_liquid_capital' => [
            {
              'description' => 'Timeshare property',
              'value' => '256000.0'
            },
            {
              'description' => 'Land',
              'value' => '100000.0'
            },
            {
              'description' => 'Valuable items',
              'value' => '32500.0'
            },
            { 'description' => 'Trusts',
              'value' => '99999.99' }
          ]
        }.to_json
      end

      let(:dummy_response) do
        {
          'objects' => {
            'id' => 'dfc616dc-b8a0-4f18-b721-57dc561aaf07',
            'assessment_id' => 'f0496616-66b9-4f3e-bf9d-ec51d14d461c',
            'total_liquid' => '0.0',
            'total_non_liquid' => '0.0',
            'total_vehicle' => '0.0',
            'total_property' => '0.0',
            'total_mortgage_allowance' => '0.0',
            'total_capital' => '0.0',
            'pensioner_capital_disregard' => '0.0',
            'assessed_capital' => '0.0',
            'capital_contribution' => '0.0',
            'lower_threshold' => '0.0',
            'upper_threshold' => '0.0',
            'capital_assessment_result' => 'pending',
            'created_at' => '2019-09-11T14:15:58.953Z',
            'updated_at' => '2019-09-11T14:15:58.953Z'
          },
          "errors": [],
          "success": true
        }.to_json
      end

      before do
        expect(Faraday).to receive(:new).with(url: 'http://localhost:3001').and_return(faraday_connection)
        expect(faraday_connection).to receive(:post).and_yield(connection_param).and_return(faraday_response)
      end

      context 'successful post' do
        let(:faraday_response) { double Faraday::Response, status: 200, body: dummy_response }
        it 'calls with expected payload and connection params' do
          expect(connection_param).to receive(:url).with("/assessments/#{submission.assessment_id}/capitals")
          expect(connection_param).to receive(:headers)
          expect(connection_param).to receive(:body=).with(expected_payload)

          CreateCapitalsService.call(submission)
        end

        it 'updates the submission record from applicant_created to capitals_created' do
          expect(submission.aasm_state).to eq 'applicant_created'
          CreateCapitalsService.call(submission)
          expect(submission.aasm_state).to eq 'capitals_created'
        end

        it 'creates a submission_history record' do
          expect {
            CreateCapitalsService.call(submission)
          }.to change { submission.submission_histories.count }.by 1
          history = CFE::SubmissionHistory.last
          expect(history.submission_id).to eq submission.id
          expect(history.url).to eq "http://localhost:3001/assessments/#{submission.assessment_id}/capitals"
          expect(history.http_method).to eq 'POST'
          expect(history.request_payload).to eq expected_payload
          expect(history.http_response_status).to eq 200
          expect(history.response_payload).to eq dummy_response
          expect(history.error_message).to be_nil
        end
      end

      describe 'unsuccessful post' do
        let(:faraday_response) { double Faraday::Response, status: 422, body: error_response }

        it 'raises an exception' do
          expect {
            CreateCapitalsService.call(submission)
          }.to raise_error CFE::SubmissionError, 'Unprocessable entity'
        end

        it 'updates the submission record from initialised to failed' do
          expect(submission.submission_histories).to be_empty
          expect { CreateCapitalsService.call(submission) }.to raise_error CFE::SubmissionError

          expect(submission.submission_histories.count).to eq 1
          history = submission.submission_histories.last
          expect(history.submission_id).to eq submission.id
          expect(history.url).to eq "http://localhost:3001/assessments/#{submission.assessment_id}/capitals"
          expect(history.http_method).to eq 'POST'
          expect(history.request_payload).to eq expected_payload
          expect(history.http_response_status).to eq 422
          expect(history.response_payload).to eq error_response
          expect(history.error_message).to be_nil
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
end
