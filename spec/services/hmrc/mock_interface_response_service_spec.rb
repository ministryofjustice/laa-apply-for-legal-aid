require 'rails_helper'

RSpec.describe HMRC::MockInterfaceResponseService do
  subject(:service) { described_class.call(hmrc_response) }

  let(:applicant) { create :applicant }
  let(:application) { create :legal_aid_application, applicant: applicant }
  let(:hmrc_response) { create :hmrc_response, :use_case_one, legal_aid_application: application, submission_id: guid }
  let(:guid) { SecureRandom.uuid }
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
                taxYear: '20-21',
                payFrequency: 'M1',
                paymentDate: '2020-12-18',
                paidHoursWorked: 'D',
                taxablePayToDate: 16_447.71,
                totalTaxToDate: 1366.6,
                dednsFromNetPay: 0,
                grossEarningsForNics: {
                  inPayPeriod1: 2526
                }
              },
              {
                taxYear: '20-21',
                payFrequency: 'M1',
                paymentDate: '2020-11-28',
                paidHoursWorked: 'D',
                taxablePayToDate: 14_156.63,
                totalTaxToDate: 1122,
                dednsFromNetPay: 0,
                grossEarningsForNics: {
                  inPayPeriod1: 2526
                }
              },
              {
                taxYear: '20-21',
                payFrequency: 'M1',
                paymentDate: '2020-10-28',
                paidHoursWorked: 'D',
                taxablePayToDate: 11_865.55,
                totalTaxToDate: 877.4,
                dednsFromNetPay: 0,
                grossEarningsForNics: {
                  inPayPeriod1: 2526
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
    expect(JSON.parse(hmrc_response.reload.response)).to match_json_expression not_found_response
  end

  it 'updates the hmrc_response.submission_id value' do
    expect(hmrc_response.reload.submission_id).to eq 'dummy_uuid'
  end

  context 'when the applicant is known to the mock response service' do
    let(:applicant) { create :applicant, first_name: 'Langley', last_name: 'Yorke', national_insurance_number: 'MN212451D', date_of_birth: '1992-07-22' }

    it 'updates the hmrc_response.response value' do
      expect(JSON.parse(hmrc_response.reload.response)).to match_json_expression employed_response
    end
  end
end
