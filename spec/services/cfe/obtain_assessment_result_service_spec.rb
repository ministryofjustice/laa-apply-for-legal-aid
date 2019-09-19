require 'rails_helper'

module CFE # rubocop:disable Metrics/ModuleLength
  RSpec.describe ObtainAssessmentResultService do
    EXPECTED_RESPONSE =
      {
        'assessment_result' => 'eligible',
        'applicant' => {
          'receives_qualifying_benefit' => false,
          'age_at_submission' => 51
        },
        'capital' => {
          'total_liquid' => '6771.93',
          'total_non_liquid' => '3570.51',
          'pensioner_capital_disregard' => '0.0',
          'total_capital' => '-86264.36',
          'capital_contribution' => '0.0',
          'liquid_capital_items' => [
            {
              'description' => 'Quia dicta laboriosam pariatur.',
              'value' => '6771.93'
            }
          ],
          'non_liquid_capital_items' => [
            {
              'description' => 'Quidem aspernatur a ducimus.',
              'value' => '3570.51'
            }
          ]
        },
        'property' => {
          'total_mortgage_allowance' => '100000.0',
          'total_property' => '-100023.77',
          'main_home' => {
            'value' => '2290.58',
            'transaction_allowance' => '68.72',
            'allowable_outstanding_mortgage' => '9424.94',
            'percentage_owned' => '0.33',
            'net_equity' => '-23.77',
            'main_home_equity_disregard' => '100000.0',
            'assessed_equity' => '-100023.77',
            'shared_with_housing_assoc' => true
          },
          'additional_properties' => []
        },
        'vehicles' => {
          'total_vehicle' => '3416.97',
          'vehicles' => [
            {
              'in_regular_use' => false,
              'included_in_assessment' => true,
              'value' => '3416.97',
              'assessed_value' => '3416.97',
              'date_of_purchase' => '2016-11-04',
              'loan_amount_outstanding' => '3515.61'
            }
          ]
        }
      }.freeze.to_json

    let(:faraday_connection) { double Faraday }
    let(:application) { create :legal_aid_application, application_ref: 'L-XYZ-999' }
    let(:submission) { create :cfe_submission, aasm_state: 'properties_created', legal_aid_application: application }
    let(:url_host) { ENV['CHECK_FINANCIAL_ELIGIBILITY_URL'] }
    let(:url_path) { "/assessments/#{submission.assessment_id}" }
    let(:full_url) { "#{url_host}#{url_path}" }

    before do
      allow(Faraday).to receive(:new).with(url: url_host).and_return(faraday_connection)
      allow(faraday_connection).to receive(:get).with(url_path).and_return(faraday_response)
    end

    context 'success' do
      let(:faraday_response) { double Faraday::Response, status: 200, body: EXPECTED_RESPONSE }

      it 'calls the expected URL' do
        expect(faraday_connection).to receive(:get).with(url_path).and_return(faraday_response)
        ObtainAssessmentResultService.call(submission)
      end

      it 'updates the submission state to results_obtained' do
        ObtainAssessmentResultService.call(submission)
        expect(submission.aasm_state).to eq 'results_obtained'
      end

      it 'stores the response in the submission cfe_result field' do
        ObtainAssessmentResultService.call(submission)
        expect(submission.cfe_result).to eq EXPECTED_RESPONSE
      end

      it 'writes a history record' do
        ObtainAssessmentResultService.call(submission)
        history = submission.submission_histories.first
        expect(history.url).to eq full_url
        expect(history.http_method).to eq 'GET'
        expect(history.request_payload).to be_nil
        expect(history.http_response_status).to eq 200
        expect(history.response_payload).to eq EXPECTED_RESPONSE
        expect(history.error_message).to be_nil
        expect(history.error_backtrace).to be_nil
      end
    end

    context 'unssuccessful call' do
      context 'http status 404' do
        let(:faraday_response) { double Faraday::Response, status: 404, body: '' }

        it 'updates the submission state to failed' do
          expect {
            ObtainAssessmentResultService.call(submission)
          }.to raise_error CFE::SubmissionError
          expect(submission.aasm_state).to eq 'failed'
        end

        it 'writes the details to the history record' do
          expect {
            ObtainAssessmentResultService.call(submission)
          }.to raise_error CFE::SubmissionError
          history = submission.submission_histories.last
          expect(history.url).to eq full_url
          expect(history.http_method).to eq 'GET'
          expect(history.request_payload).to be_nil
          expect(history.http_response_status).to eq 404
          expect(history.response_payload).to be_nil
          expect(history.error_message).to eq 'CFE::ObtainAssessmentResultService received CFE::SubmissionError: Unsuccessful HTTP response code'
          expect(history.error_backtrace).to be_nil
        end
      end
    end
  end
end
