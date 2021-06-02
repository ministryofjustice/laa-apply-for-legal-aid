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
    let(:expected_response) { expected_response_hash.to_json }
    let(:expected_v4_response) { expected_v4_response_hash.to_json }
    let(:service) { described_class.new(submission) }

    describe '#cfe_url' do
      it 'contains the submission assessment id' do
        expect(service.cfe_url)
          .to eq "#{Rails.configuration.x.check_financial_eligibility_host}/assessments/#{submission.assessment_id}"
      end
    end

    describe 'private method #headers' do
      context 'obtain version 3 cfe response' do
        it 'includes version=3 in the Accept header' do
          expect(service.__send__(:headers))
            .to eq(
              {
                'Content-Type' => 'application/json',
                'Accept' => 'application/json;version=3'
              }
            )
        end

        context 'success' do
          before do
            stub_request(:get, service.cfe_url)
              .to_return(body: expected_response)
          end

          it 'updates the submission state to results_obtained' do
            ObtainAssessmentResultService.call(submission)
            expect(submission.aasm_state).to eq 'results_obtained'
          end

          it 'stores the response in the submission cfe_result field' do
            ObtainAssessmentResultService.call(submission)
            expect(submission.cfe_result).to eq expected_response
          end

          it 'writes a history record' do
            ObtainAssessmentResultService.call(submission)
            history = submission.submission_histories.first
            expect(history.url).to eq service.cfe_url
            expect(history.http_method).to eq 'GET'
            expect(history.request_payload).to be_nil
            expect(history.http_response_status).to eq 200
            expect(history.response_payload).to eq expected_response
            expect(history.error_message).to be_nil
            expect(history.error_backtrace).to be_nil
          end
        end
      end

      context 'obtain version 4 cfe response' do
        before { allow(Setting).to receive(:allow_multiple_proceedings?).and_return(true) }

        it 'includes version=4 in the Accept header' do
          expect(service.__send__(:headers))
            .to eq(
              {
                'Content-Type' => 'application/json',
                'Accept' => 'application/json;version=4'
              }
            )
        end

        context 'success' do
          before do
            stub_request(:get, service.cfe_url)
              .to_return(body: expected_v4_response)
          end

          it 'updates the submission state to results_obtained' do
            ObtainAssessmentResultService.call(submission)
            expect(submission.aasm_state).to eq 'results_obtained'
          end

          it 'stores the response in the submission cfe_result field' do
            ObtainAssessmentResultService.call(submission)
            expect(submission.cfe_result).to eq expected_v4_response
          end

          it 'writes a history record' do
            ObtainAssessmentResultService.call(submission)
            history = submission.submission_histories.first
            expect(history.url).to eq service.cfe_url
            expect(history.http_method).to eq 'GET'
            expect(history.request_payload).to be_nil
            expect(history.http_response_status).to eq 200
            expect(history.response_payload).to eq expected_v4_response
            expect(history.error_message).to be_nil
            expect(history.error_backtrace).to be_nil
          end
        end
      end
    end

    context 'unsuccessful call' do
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

    def default_response_hash
      {
        timestamp: '2020-01-28T16:37:07.921+00:00',
        success: true,
        assessment: {
          id: '41188692-9fa1-488d-818f-67f8509ff21a',
          client_reference_id: 'CLIENT-REF-0007',
          submission_date: '2020-01-28',
          matter_proceeding_type: 'domestic_abuse',
          assessment_result: 'eligible',
          applicant: {
            date_of_birth: '1996-08-15',
            involvement_type: 'applicant',
            has_partner_opponent: false,
            receives_qualifying_benefit: false,
            self_employed: false
          },
          capital: {
            capital_items: {
              liquid: [
                {
                  description: 'Ab quasi autem rerum.',
                  value: '6692.12'
                }
              ],
              non_liquid: [
                {
                  description: 'Omnis sit et corrupti.',
                  value: '3902.92'
                }
              ],
              vehicles: [
                {
                  value: '1784.61',
                  loan_amount_outstanding: '3225.77',
                  date_of_purchase: '2014-07-01',
                  in_regular_use: true,
                  included_in_assessment: false,
                  assessed_value: '0.0'
                }
              ],
              properties: {
                main_home: {
                  value: '5985.82',
                  outstanding_mortgage: '7201.44',
                  percentage_owned: '1.87',
                  main_home: true,
                  shared_with_housing_assoc: false,
                  transaction_allowance: '179.57',
                  allowable_outstanding_mortgage: '7201.44',
                  net_value: '-1395.19',
                  net_equity: '-26.09',
                  main_home_equity_disregard: '100000.0',
                  assessed_equity: '0.0'
                },
                additional_properties: [
                  {
                    value: '0.0',
                    outstanding_mortgage: '8202.39',
                    percentage_owned: '8.33',
                    main_home: false,
                    shared_with_housing_assoc: true,
                    transaction_allowance: '113.46',
                    allowable_outstanding_mortgage: '8202.39',
                    net_value: '-4533.94',
                    net_equity: '-8000.82',
                    main_home_equity_disregard: '0.0',
                    assessed_equity: '0.0'
                  }
                ]
              }
            },
            total_liquid: '5649.13',
            total_non_liquid: '3902.92',
            total_vehicle: '0.0',
            total_property: '1134.0',
            total_mortgage_allowance: '100000.0',
            total_capital: '9552.05',
            pensioner_capital_disregard: '0.0',
            assessed_capital: '9552.05',
            lower_threshold: '3000.0',
            upper_threshold: '999999999999.0',
            assessment_result: 'contribution_required',
            capital_contribution: '6552.05'
          }
        }
      }
    end

    def expected_v4_response_hash
      {
        version: '4',
        timestamp: '2021-04-29T15:44:53.000Z',
        success: true,
        result_summary: {
          overall_result: {
            result: 'contribution_required',
            capital_contribution: 38_500.0,
            income_contribution: 0.0,
            matter_types: [
              {
                matter_type: 'domestic_abuse',
                result: 'contribution_required'
              }
            ],
            proceeding_types: [
              {
                ccms_code: 'DA001',
                result: 'contribution_required'
              }
            ]
          },
          gross_income: {
            total_gross_income: 1615.0,
            proceeding_types: [
              {
                ccms_code: 'DA001',
                upper_threshold: 999_999_999_999.0,
                result: 'eligible'
              }
            ]
          },
          disposable_income: {
            dependant_allowance: 1457.45,
            gross_housing_costs: 50.0,
            housing_benefit: 0.0,
            net_housing_costs: 50.0,
            maintenance_allowance: 0.0,
            total_outgoings_and_allowances: 1507.45,
            total_disposable_income: 107.55,
            income_contribution: 0.0,
            proceeding_types: [
              {
                ccms_code: 'DA001',
                upper_threshold: 999_999_999_999.0,
                lower_threshold: 315.0,
                result: 'eligible'
              }
            ]
          },
          capital: {
            total_liquid: 0.0,
            total_non_liquid: 0.0,
            total_vehicle: 9000.0,
            total_property: 92_500.0,
            total_mortgage_allowance: 100_000.0,
            total_capital: 101_500.0,
            pensioner_capital_disregard: 60_000.0,
            capital_contribution: 38_500.0,
            assessed_capital: 41_500.0,
            proceeding_types: [
              {
                ccms_code: 'DA001',
                lower_threshold: 3000.0,
                upper_threshold: 999_999_999_999.0,
                result: 'contribution_required'
              }
            ]
          }
        },
        assessment: {
          id: '53448494-5481-4b65-95b8-2afb6e7bc862',
          client_reference_id: 'NPE6-1',
          submission_date: '2019-05-29',
          applicant: {
            date_of_birth: '1990-07-15',
            involvement_type: 'applicant',
            has_partner_opponent: false,
            receives_qualifying_benefit: false,
            self_employed: false
          },
          gross_income: {
            irregular_income: {
              monthly_equivalents: {
                student_loan: 0.0
              }
            },
            state_benefits: {
              monthly_equivalents: {
                all_sources: 200.0,
                cash_transactions: 0.0,
                bank_transactions: [
                  {
                    name: 'Child Benefit',
                    monthly_value: 200.0,
                    excluded_from_income_assessment: false
                  }
                ]
              }
            },
            other_income: {
              monthly_equivalents: {
                all_sources: {
                  friends_or_family: 1415.0,
                  maintenance_in: 0.0,
                  property_or_lodger: 0.0,
                  pension: 0.0
                },
                bank_transactions: {
                  friends_or_family: 1415.0,
                  maintenance_in: 0.0,
                  property_or_lodger: 0.0,
                  pension: 0.0
                },
                cash_transactions: {
                  friends_or_family: 0.0,
                  maintenance_in: 0.0,
                  property_or_lodger: 0.0,
                  pension: 0.0
                }
              }
            }
          },
          disposable_income: {
            monthly_equivalents: {
              all_sources: {
                child_care: 0.0,
                rent_or_mortgage: 50.0,
                maintenance_out: 0.0,
                legal_aid: 0.0
              },
              bank_transactions: {
                child_care: 0.0,
                rent_or_mortgage: 50.0,
                maintenance_out: 0.0,
                legal_aid: 0.0
              },
              cash_transactions: {
                child_care: 0.0,
                rent_or_mortgage: 0.0,
                maintenance_out: 0.0,
                legal_aid: 0.0
              }
            },
            childcare_allowance: 0.0,
            deductions: {
              dependants_allowance: 1457.45,
              disregarded_state_benefits: 0.0
            }
          },
          capital: {
            capital_items: {
              liquid: [
                {
                  description: 'Bank acct 1',
                  value: 0.0
                },
                {
                  description: 'Bank acct 2',
                  value: 0.0
                },
                {
                  description: 'Bank acct 3',
                  value: 0.0
                }
              ],
              non_liquid: [],
              vehicles: [
                {
                  value: 9000.0,
                  loan_amount_outstanding: 0.0,
                  date_of_purchase: '2018-05-20',
                  in_regular_use: false,
                  included_in_assessment: true,
                  assessed_value: 9000.0
                }
              ],
              properties: {
                main_home: {
                  value: 500_000.0,
                  outstanding_mortgage: 150_000.0,
                  percentage_owned: 50.0,
                  main_home: true,
                  shared_with_housing_assoc: false,
                  transaction_allowance: 15_000.0,
                  allowable_outstanding_mortgage: 100_000.0,
                  net_value: 385_000.0,
                  net_equity: 192_500.0,
                  main_home_equity_disregard: 100_000.0,
                  assessed_equity: 92_500.0
                },
                additional_properties: []
              }
            }
          },
          remarks: {
            state_benefit_payment: {
              amount_variation: %w[
                4b84cd39-bb3e-4603-9470-b64df27c72f2
                306ef3e1-9316-402e-b6f7-c87cdafbd790
                934b2ecb-015c-4f55-84ca-a8ec6614ddde
              ],
              unknown_frequency: %w[
                4b84cd39-bb3e-4603-9470-b64df27c72f2
                306ef3e1-9316-402e-b6f7-c87cdafbd790
                934b2ecb-015c-4f55-84ca-a8ec6614ddde
              ]
            }
          }
        }
      }
    end

    def expected_response_hash
      hash = default_response_hash
      hash[:version] = '3'
      hash[:assessment][:gross_income] = {
        summary: {
          total_gross_income: '3264.66',
          upper_threshold: '999999999999.0',
          assessment_result: 'eligible'
        },
        irregular_income: {
          monthly_equivalents: {
            student_loan: '0.0'
          }
        },
        state_benefits: {
          monthly_equivalents: {
            all_sources: '114.95',
            cash_transactions: '100.0',
            bank_transactions: [
              {
                name: 'manually_chosen',
                monthly_value: '14.95',
                excluded_from_income_assessment: false
              }
            ]
          }
        },
        other_income: {
          monthly_equivalents: {
            bank_transactions: {
              friends_or_family: '36.67',
              maintenance_in: '10.0',
              property_or_lodger: '666.67',
              pension: '16.67'
            },
            cash_transactions: {
              friends_or_family: '200.0',
              maintenance_in: '300.0',
              property_or_lodger: '400.0',
              pension: '500.0'
            },
            all_sources: {
              friends_or_family: '236.67',
              maintenance_in: '310.0',
              property_or_lodger: '1066.67',
              pension: '516.67'
            }
          }
        }
      }
      hash[:assessment][:disposable_income] = {
        monthly_equivalents: {
          bank_transactions: {
            child_care: '5.06',
            rent_or_mortgage: '19.5',
            maintenance_out: '66.81',
            legal_aid: '6.49'
          },
          cash_transactions: {
            child_care: '200.0',
            rent_or_mortgage: '100.0',
            maintenance_out: '300.0',
            legal_aid: '400.0'
          },
          all_sources: {
            child_care: '205.06',
            rent_or_mortgage: '119.5',
            maintenance_out: '366.81',
            legal_aid: '406.49'
          }
        },
        childcare_allowance: '0.0',
        deductions: {
          dependants_allowance: '291.49',
          disregarded_state_benefits: '0.0'
        },
        dependant_allowance: '291.49',
        maintenance_allowance: '0.0',
        gross_housing_costs: '119.5',
        housing_benefit: '0.0',
        net_housing_costs: '119.5',
        total_outgoings_and_allowances: '1489.35',
        total_disposable_income: '1775.31',
        lower_threshold: '315.0',
        upper_threshold: '999999999999.0',
        assessment_result: 'contribution_required',
        income_contribution: '933.37'
      }
      hash
    end
  end
end
