require 'rails_helper'

RSpec.describe HMRC::MockInterfaceResponseService do
  subject(:service) { described_class.call(hmrc_response) }

  let(:applicant) { create :applicant }
  let(:application) { create :legal_aid_application, applicant: applicant }
  let(:hmrc_response) { create :hmrc_response, :use_case_one, legal_aid_application: application, submission_id: guid }
  let(:guid) { SecureRandom.uuid }
  let(:hmrc_data) { hmrc_response.response['data'] }
  let(:not_found_response) do
    {
      submission: guid,
      status: 'failed',
      data:
        [
          {
            correlation_id: guid,
            use_case: 'use_case_one'
          },
          {
            error: 'submitted client details could not be found in HMRC service'
          }
        ]
    }
  end

  let(:employed_response) do
    {
      submission: guid,
      status: 'completed',
      data: [
        {
          correlation_id: guid,
          use_case: 'use_case_one'
        },
        {
          'individuals/matching/individual': {
            firstName: 'Langley',
            lastName: 'Yorke',
            nino: 'MN212451D',
            dateOfBirth: '1992-07-22'
          }
        },
        {
          'income/paye/paye': {
            income: [
              {
                taxYear: '21-22',
                payFrequency: 'M1',
                monthPayNumber: 8,
                paymentDate: '2021-11-30',
                paidHoursWorked: 'E',
                taxablePayToDate: 17_666.66,
                taxablePay: 2083.33,
                totalTaxToDate: 1848,
                taxDeductedOrRefunded: 206,
                grossEarningsForNics: {
                  inPayPeriod1: 2083.33
                },
                totalEmployerNics: {
                  inPayPeriod1: 185.79,
                  ytd1: 1624.32
                },
                employeeNics: {
                  inPayPeriod1: 154.36,
                  ytd1: 1354.88
                }
              },
              {
                taxYear: '21-22',
                payFrequency: 'M1',
                monthPayNumber: 7,
                paymentDate: '2021-10-29',
                paidHoursWorked: 'E',
                taxablePayToDate: 15_583.33,
                taxablePay: 3083.33,
                totalTaxToDate: 1642,
                taxDeductedOrRefunded: 406,
                grossEarningsForNics: {
                  inPayPeriod1: 3083.33
                },
                totalEmployerNics: {
                  inPayPeriod1: 323.79,
                  ytd1: 1438.53
                },
                employeeNics: {
                  inPayPeriod1: 274.36,
                  ytd1: 1200.52
                }
              },
              {
                taxYear: '21-22',
                payFrequency: 'M1',
                monthPayNumber: 6,
                paymentDate: '2021-09-30',
                paidHoursWorked: 'E',
                taxablePayToDate: 12_500,
                taxablePay: 2000,
                totalTaxToDate: 1236,
                taxDeductedOrRefunded: 189.4,
                grossEarningsForNics: {
                  inPayPeriod1: 2000
                },
                totalEmployerNics: {
                  inPayPeriod1: 174.29,
                  ytd1: 1114.74
                },
                employeeNics: {
                  inPayPeriod1: 144.36,
                  ytd1: 926.16
                }
              },
              {
                taxYear: '21-22',
                payFrequency: 'M1',
                monthPayNumber: 5,
                paymentDate: '2021-08-31',
                paidHoursWorked: 'E',
                taxablePayToDate: 10_500,
                taxablePay: 1750,
                totalTaxToDate: 1046.6,
                taxDeductedOrRefunded: 139.4,
                grossEarningsForNics: {
                  inPayPeriod1: 1750
                },
                totalEmployerNics: {
                  inPayPeriod1: 139.79,
                  ytd1: 940.45
                },
                employeeNics: {
                  inPayPeriod1: 114.36,
                  ytd1: 781.8
                }
              }
            ]
          }
        },
        {
          'income/sa/selfAssessment': {
            registrations: [],
            taxReturns: []
          }
        },
        {
          'income/sa/pensions_and_state_benefits/selfAssessment': {
            taxReturns: []
          }
        },
        {
          'income/sa/source/selfAssessment': {
            taxReturns: []
          }
        },
        {
          'income/sa/employments/selfAssessment': {
            taxReturns: []
          }
        },
        {
          'income/sa/additional_information/selfAssessment': {
            taxReturns: []
          }
        },
        {
          'income/sa/partnerships/selfAssessment': {
            taxReturns: []
          }
        },
        {
          'income/sa/uk_properties/selfAssessment': {
            taxReturns: []
          }
        },
        {
          'income/sa/foreign/selfAssessment': {
            taxReturns: []
          }
        },
        {
          'income/sa/further_details/selfAssessment': {
            taxReturns: []
          }
        },
        {
          'income/sa/interests_and_dividends/selfAssessment': {
            taxReturns: []
          }
        },
        {
          'income/sa/other/selfAssessment': {
            taxReturns: []
          }
        },
        {
          'income/sa/summary/selfAssessment': {
            taxReturns: []
          }
        },
        {
          'income/sa/trusts/selfAssessment': {
            taxReturns: []
          }
        },
        {
          'employments/paye/employments': [
            {
              startDate: '2017-07-24',
              endDate: '2099-12-31'
            }
          ]
        },
        {
          'benefits_and_credits/working_tax_credit/applications': []
        },
        {
          'benefits_and_credits/child_tax_credit/applications': []
        }
      ]
    }
  end

  before do
    allow(SecureRandom).to receive(:uuid).and_return('dummy_uuid')
    service
  end

  it 'updates the hmrc_response.response value' do
    expect(hmrc_response.reload.response).to match_json_expression not_found_response
  end

  it 'updates the hmrc_response.submission_id value' do
    expect(hmrc_response.reload.submission_id).to eq 'dummy_uuid'
  end

  context 'when the applicant is known to the mock response service' do
    let(:applicant) { create :applicant, first_name: 'Langley', last_name: 'Yorke', national_insurance_number: 'MN212451D', date_of_birth: '1992-07-22' }

    it 'updates the hmrc_response.response value' do
      expect(hmrc_response.reload.response).to match_json_expression employed_response
    end

    context 'and is paid weekly' do
      let(:applicant) { create :applicant, first_name: 'Jeremy', last_name: 'Irons', national_insurance_number: 'BB313661B', date_of_birth: '1966-06-06' }

      it 'updates the hmrc_response.response value' do
        ap hmrc_data
        expect(hmrc_data[1]['individuals/matching/individual']['firstName']).to eq 'Jeremy'
        expect(hmrc_data[2]['income/paye/paye']['income'][0]['payFrequency']).to eq 'W4'
      end
    end

    context 'and has multiple employments' do
      let(:applicant) { create :applicant, first_name: 'Ida', last_name: 'Paisley', national_insurance_number: 'OE726113A', date_of_birth: '1987-11-24' }

      it 'updates the hmrc_response.response value' do
        expect(hmrc_data[1]['individuals/matching/individual']['firstName']).to eq 'Ida'
        expect(hmrc_data[2]['income/paye/paye']['income'][0]['payFrequency']).to eq 'W4'
        expect(hmrc_data[2]['income/paye/paye']['income'][1]['payFrequency']).to eq 'W1'
        expect(hmrc_data[16]['employments/paye/employments'].size).to eq 4
      end
    end

    context 'and receives tax credits' do
      let(:applicant) { create :applicant, first_name: 'Oakley', last_name: 'Weller', national_insurance_number: 'AB476107D', date_of_birth: '1988-08-08' }

      it 'updates the hmrc_response.response value' do
        expect(hmrc_data[1]['individuals/matching/individual']['firstName']).to eq 'Oakley'
        expect(hmrc_data[17]['benefits_and_credits/working_tax_credit/applications'][0]['awards'][0]['totalEntitlement']).not_to be_nil
      end
    end
  end
end
