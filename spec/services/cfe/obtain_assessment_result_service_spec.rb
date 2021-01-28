require 'rails_helper'

module CFE # rubocop:disable Metrics/ModuleLength
  RSpec.describe ObtainAssessmentResultService do
    around do |example|
      VCR.turn_off!
      example.run
      VCR.turn_on!
    end

    let(:application) { create :legal_aid_application, :with_positive_benefit_check_result, application_ref: 'L-XYZ-999' }
    let(:submission) { create :cfe_submission, aasm_state: 'explicit_remarks_created', legal_aid_application: application }
    let(:expected_v2_response) { expected_v2_response_hash.to_json }
    let(:service) { described_class.new(submission) }

    describe '#cfe_url' do
      it 'contains the submission assessment id' do
        expect(service.cfe_url)
          .to eq "#{Rails.configuration.x.check_financial_eligibility_host}/assessments/#{submission.assessment_id}"
      end
    end

    describe 'private method #headers' do
      context 'cash payments are not enabled' do
        it 'includes version=2 in the Accept header' do
          expect(service.__send__(:headers))
            .to eq(
              {
                'Content-Type' => 'application/json',
                'Accept' => 'application/json;version=2'
              }
            )
        end
      end

      context 'cash payments are enabled' do
        before { Setting.setting.update!(allow_cash_payment: true) }
        after { Setting.setting.update!(allow_cash_payment: false) }

        it 'includes version=3 in the Accept header' do
          expect(service.__send__(:headers))
            .to eq(
              {
                'Content-Type' => 'application/json',
                'Accept' => 'application/json;version=3'
              }
            )
        end
      end
    end

    context 'success for v2' do
      before do
        stub_request(:get, service.cfe_url)
          .to_return(body: expected_v2_response)
      end

      it 'updates the submission state to results_obtained' do
        ObtainAssessmentResultService.call(submission)
        expect(submission.aasm_state).to eq 'results_obtained'
      end

      it 'stores the response in the submission cfe_result field' do
        ObtainAssessmentResultService.call(submission)
        expect(submission.cfe_result).to eq expected_v2_response
      end

      it 'writes a history record' do
        ObtainAssessmentResultService.call(submission)
        history = submission.submission_histories.first
        expect(history.url).to eq service.cfe_url
        expect(history.http_method).to eq 'GET'
        expect(history.request_payload).to be_nil
        expect(history.http_response_status).to eq 200
        expect(history.response_payload).to eq expected_v2_response
        expect(history.error_message).to be_nil
        expect(history.error_backtrace).to be_nil
      end
    end

    context 'unssuccessful call' do
      context 'http status 404' do
        before do
          stub_request(:get, service.cfe_url)
            .to_return(body: '', status: 404)
        end

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
          expect(history.url).to eq service.cfe_url
          expect(history.http_method).to eq 'GET'
          expect(history.request_payload).to be_nil
          expect(history.http_response_status).to eq 404
          expect(history.response_payload).to be_nil
          expect(history.error_message).to eq 'CFE::ObtainAssessmentResultService received CFE::SubmissionError: Unsuccessful HTTP response code'
          expect(history.error_backtrace).to be_nil
        end
      end
    end

    def expected_v2_response_hash # rubocop:disable Metrics/MethodLength
      {
        "version": '2',
        "timestamp": '2020-01-28T16:37:07.921+00:00',
        "success": true,
        "assessment": {
          "id": '41188692-9fa1-488d-818f-67f8509ff21a',
          "client_reference_id": 'CLIENT-REF-0007',
          "submission_date": '2020-01-28',
          "matter_proceeding_type": 'domestic_abuse',
          "assessment_result": 'eligible',
          "applicant": {
            "date_of_birth": '1996-08-15',
            "involvement_type": 'applicant',
            "has_partner_opponent": false,
            "receives_qualifying_benefit": false,
            "self_employed": false
          },
          "gross_income": {
            "monthly_other_income": '75.0',
            "monthly_state_benefits": '75.0',
            "total_gross_income": '150.0',
            "upper_threshold": '999999999999.0',
            "assessment_result": 'eligible',
            "state_benefits": [
              {
                "name": 'benefit_type_1',
                "monthly_value": '75.0',
                "excluded_from_income_assessment": true,
                "state_benefit_payments": [
                  {
                    "payment_date": '2020-01-28',
                    "amount": '75.0'
                  },
                  {
                    "payment_date": '2019-12-28',
                    "amount": '75.0'
                  },
                  {
                    "payment_date": '2019-11-28',
                    "amount": '75.0'
                  }
                ]
              }
            ],
            "other_income": [
              {
                "name": 'Trust fund',
                "monthly_income": '75.0',
                "payments": [
                  {
                    "payment_date": '2020-01-28',
                    "amount": '75.0'
                  },
                  {
                    "payment_date": '2019-12-28',
                    "amount": '75.0'
                  },
                  {
                    "payment_date": '2019-11-28',
                    "amount": '75.0'
                  }
                ]
              }
            ]
          },
          "disposable_income": {
            "outgoings": {
              "childcare_costs": [
                {
                  "payment_date": '2020-01-28',
                  "amount": '100.0'
                },
                {
                  "payment_date": '2019-12-28',
                  "amount": '100.0'
                },
                {
                  "payment_date": '2019-11-28',
                  "amount": '100.0'
                }
              ],
              "housing_costs": [
                {
                  "payment_date": '2020-01-28',
                  "amount": '125.0'
                },
                {
                  "payment_date": '2019-12-28',
                  "amount": '125.0'
                },
                {
                  "payment_date": '2019-11-28',
                  "amount": '125.0'
                }
              ],
              "maintenance_costs": [
                {
                  "payment_date": '2020-01-28',
                  "amount": '50.0'
                },
                {
                  "payment_date": '2019-12-28',
                  "amount": '50.0'
                },
                {
                  "payment_date": '2019-11-28',
                  "amount": '50.0'
                }
              ]
            },
            "childcare_allowance": '0.0',
            "dependant_allowance": '0.0',
            "maintenance_allowance": '50.0',
            "gross_housing_costs": '125.0',
            "housing_benefit": '0.0',
            "net_housing_costs": '125.0',
            "total_outgoings_and_allowances": '175.0',
            "total_disposable_income": '0.0',
            "lower_threshold": '315.0',
            "upper_threshold": '733.0',
            "assessment_result": 'eligible',
            "income_contribution": '0.0'
          },
          "capital": {
            "capital_items": {
              "liquid": [
                {
                  "description": 'Ab quasi autem rerum.',
                  "value": '6692.12'
                }
              ],
              "non_liquid": [
                {
                  "description": 'Omnis sit et corrupti.',
                  "value": '3902.92'
                }
              ],
              "vehicles": [
                {
                  "value": '1784.61',
                  "loan_amount_outstanding": '3225.77',
                  "date_of_purchase": '2014-07-01',
                  "in_regular_use": true,
                  "included_in_assessment": false,
                  "assessed_value": '0.0'
                }
              ],
              "properties": {
                "main_home": {
                  "value": '5985.82',
                  "outstanding_ mortgage": '7201.44',
                  "percentage_owned": '1.87',
                  "main_home": true,
                  "shared_with_housing_assoc": false,
                  "transaction_allowance": '179.57',
                  "allowable_outstanding_mortgage": '7201.44',
                  "net_value": '-1395.19',
                  "net_equity": '-26.09',
                  "main_home_equity_disregard": '100000.0',
                  "assessed_equity": '0.0'
                },
                "additional_properties": [
                  {
                    "value": '0.0',
                    "outstanding_mortgage": '8202.39',
                    "percentage_owned": '8.33',
                    "main_home": false,
                    "shared_with_housing_assoc": true,
                    "transaction_allowance": '113.46',
                    "allowable_outstanding_mortgage": '8202.39',
                    "net_value": '-4533.94',
                    "net_equity": '-8000.82',
                    "main_home_equity_disregard": '0.0',
                    "assessed_equity": '0.0'
                  }
                ]
              }
            },
            "total_liquid": '5649.13',
            "total_non_liquid": '3902.92',
            "total_vehicle": '0.0',
            "total_property": '1134.0',
            "total_mortgage_allowance": '100000.0',
            "total_capital": '9552.05',
            "pensioner_capital_disregard": '0.0',
            "assessed_capital": '9552.05',
            "lower_threshold": '3000.0',
            "upper_threshold": '999999999999.0',
            "assessment_result": 'contribution_required',
            "capital_contribution": '6552.05'
          }
        }
      }
    end
  end
end
