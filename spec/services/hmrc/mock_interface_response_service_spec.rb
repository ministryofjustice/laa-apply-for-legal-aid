require "rails_helper"

RSpec.describe HMRC::MockInterfaceResponseService do
  subject(:service) { described_class.call(hmrc_response) }

  let(:applicant) { create(:applicant) }
  let(:application) { create(:legal_aid_application, applicant:) }
  let(:owner) { applicant }
  let(:hmrc_response) { create(:hmrc_response, :use_case_one, legal_aid_application: application, submission_id: guid, owner_id: owner.id, owner_type: owner.class) }
  let(:guid) { SecureRandom.uuid }
  let(:hmrc_data) { hmrc_response.response["data"] }
  let(:not_found_response) do
    {
      submission: guid,
      status: "failed",
      data:
        [
          {
            correlation_id: guid,
            use_case: "use_case_one",
          },
          {
            error: "submitted client details could not be found in HMRC service",
          },
        ],
    }
  end

  let(:employed_response) do
    {
      submission: guid,
      status: "completed",
      data: [
        {
          correlation_id: guid,
          use_case: "use_case_one",
        },
        {
          "individuals/matching/individual": {
            firstName: "Langley",
            lastName: "Yorke",
            nino: "MN212451D",
            dateOfBirth: "1992-07-22",
          },
        },
        {
          "income/paye/paye": {
            income: [
              {
                taxYear: "21-22",
                payFrequency: "M1",
                monthPayNumber: 8,
                paymentDate: "2021-11-30",
                paidHoursWorked: "E",
                taxablePayToDate: 17_666.66,
                taxablePay: 2083.33,
                totalTaxToDate: 1848,
                taxDeductedOrRefunded: 206,
                grossEarningsForNics: {
                  inPayPeriod1: 2083.33,
                },
                totalEmployerNics: {
                  inPayPeriod1: 185.79,
                  ytd1: 1624.32,
                },
                employeeNics: {
                  inPayPeriod1: 154.36,
                  ytd1: 1354.88,
                },
              },
              {
                taxYear: "21-22",
                payFrequency: "M1",
                monthPayNumber: 7,
                paymentDate: "2021-10-29",
                paidHoursWorked: "E",
                taxablePayToDate: 15_583.33,
                taxablePay: 3083.33,
                totalTaxToDate: 1642,
                taxDeductedOrRefunded: 406,
                grossEarningsForNics: {
                  inPayPeriod1: 3083.33,
                },
                totalEmployerNics: {
                  inPayPeriod1: 323.79,
                  ytd1: 1438.53,
                },
                employeeNics: {
                  inPayPeriod1: 274.36,
                  ytd1: 1200.52,
                },
              },
              {
                taxYear: "21-22",
                payFrequency: "M1",
                monthPayNumber: 6,
                paymentDate: "2021-09-30",
                paidHoursWorked: "E",
                taxablePayToDate: 12_500,
                taxablePay: 2000,
                totalTaxToDate: 1236,
                taxDeductedOrRefunded: 189.4,
                grossEarningsForNics: {
                  inPayPeriod1: 2000,
                },
                totalEmployerNics: {
                  inPayPeriod1: 174.29,
                  ytd1: 1114.74,
                },
                employeeNics: {
                  inPayPeriod1: 144.36,
                  ytd1: 926.16,
                },
              },
              {
                taxYear: "21-22",
                payFrequency: "M1",
                monthPayNumber: 5,
                paymentDate: "2021-08-31",
                paidHoursWorked: "E",
                taxablePayToDate: 10_500,
                taxablePay: 1750,
                totalTaxToDate: 1046.6,
                taxDeductedOrRefunded: 139.4,
                grossEarningsForNics: {
                  inPayPeriod1: 1750,
                },
                totalEmployerNics: {
                  inPayPeriod1: 139.79,
                  ytd1: 940.45,
                },
                employeeNics: {
                  inPayPeriod1: 114.36,
                  ytd1: 781.8,
                },
              },
            ],
          },
        },
        {
          "income/sa/selfAssessment": {
            registrations: [],
            taxReturns: [],
          },
        },
        {
          "income/sa/pensions_and_state_benefits/selfAssessment": {
            taxReturns: [],
          },
        },
        {
          "income/sa/source/selfAssessment": {
            taxReturns: [],
          },
        },
        {
          "income/sa/employments/selfAssessment": {
            taxReturns: [],
          },
        },
        {
          "income/sa/additional_information/selfAssessment": {
            taxReturns: [],
          },
        },
        {
          "income/sa/partnerships/selfAssessment": {
            taxReturns: [],
          },
        },
        {
          "income/sa/uk_properties/selfAssessment": {
            taxReturns: [],
          },
        },
        {
          "income/sa/foreign/selfAssessment": {
            taxReturns: [],
          },
        },
        {
          "income/sa/further_details/selfAssessment": {
            taxReturns: [],
          },
        },
        {
          "income/sa/interests_and_dividends/selfAssessment": {
            taxReturns: [],
          },
        },
        {
          "income/sa/other/selfAssessment": {
            taxReturns: [],
          },
        },
        {
          "income/sa/summary/selfAssessment": {
            taxReturns: [],
          },
        },
        {
          "income/sa/trusts/selfAssessment": {
            taxReturns: [],
          },
        },
        {
          "employments/paye/employments": [
            {
              startDate: "2017-07-24",
              endDate: "2099-12-31",
            },
          ],
        },
        {
          "benefits_and_credits/working_tax_credit/applications": [],
        },
        {
          "benefits_and_credits/child_tax_credit/applications": [],
        },
      ],
    }
  end

  let(:pending_response) do
    {
      submission: guid,
      status: "processing",
      _links: [
        {
          href: "https://main-laa-hmrc-interface-uat.cloud-platform.service.justice.gov.uk/api/v1/submission/status/2151e48d-b88b-4c1e-af97-7987295f687f",
        },
      ],
    }
  end

  let(:unknown_response) do
    {
      submission: guid,
      status: "completed",
      data: [
        {
          correlation_id: "794cb770-6024-4eba-ae59-5ae9857f0a2d",
          use_case: "use_case_one",
        },
        {
          "individuals/matching/individual": {
            firstName: "Henry",
            lastName: "Unknown",
            nino: "WX311689D",
            dateOfBirth: "1982-06-15",
          },
        },
        {
          "income/paye/paye": {
            income: [
              {
                taxYear: "20-21",
                payFrequency: "M1",
                paymentDate: "2020-12-18",
                paidHoursWorked: "D",
                taxablePayToDate: 16_447.71,
                totalTaxToDate: 1366.6,
                dednsFromNetPay: "£0",
                grossEarningsForNics: {
                  inPayPeriod1: "Text",
                },
              },
              {
                taxYear: "20-21",
                payFrequency: "M1",
                paymentDate: "2020-11-18",
                paidHoursWorked: "D",
                taxablePayToDate: 14_156.63,
                totalTaxToDate: 1122,
                dednsFromNetPay: 0,
                grossEarningsForNics: {
                  inPayPeriod1: 2526,
                },
              },
              {
                taxYear: "20-21",
                payFrequency: "M1",
                paymentDate: "2020-10-18",
                paidHoursWorked: "D",
                taxablePayToDate: 11_865.55,
                totalTaxToDate: 877.4,
                dednsFromNetPay: "Text",
                grossEarningsForNics: {
                  inPayPeriod1: "£2526",
                },
              },
            ],
          },
        },
        {
          "employments/paye/employments": [
            {
              startDate: "2017-07-24",
              endDate: "Ongoing",
            },
          ],
        },
      ],
    }
  end

  let(:additional_before_actions) { {} }

  before do
    allow(SecureRandom).to receive(:uuid).and_return("dummy_uuid")
    additional_before_actions
    service
  end

  it "updates the hmrc_response.response value" do
    expect(hmrc_response.reload.response).to match_json_expression not_found_response
  end

  it "updates the hmrc_response.submission_id value" do
    expect(hmrc_response.reload.submission_id).to eq "dummy_uuid"
  end

  context "when the applicant is known to the mock response service" do
    let(:applicant) { create(:applicant, first_name: "Langley", last_name: "Yorke", national_insurance_number: "MN212451D", date_of_birth: "1992-07-22") }
    let(:additional_before_actions) { allow(application).to receive(:calculation_date).and_return(Date.new(2021, 11, 30)) }

    it "updates the hmrc_response.response value" do
      expect(hmrc_response.reload.response).to match_json_expression employed_response
    end

    context "when the response is pending from HMRC" do
      let(:applicant) { create(:applicant, first_name: "John", last_name: "Pending", national_insurance_number: "KY123456D", date_of_birth: "2002-09-01") }

      it "updates the hmrc_response.response value" do
        expect(hmrc_response.reload.response).to match_json_expression pending_response
      end
    end

    context "when the response from HMRC contains unexpected data" do
      let(:applicant) { create(:applicant, first_name: "Henry", last_name: "Unknown", national_insurance_number: "WX311689D", date_of_birth: "1982-06-15") }
      let(:additional_before_actions) { allow(application).to receive(:calculation_date).and_return(Date.new(2020, 12, 18)) }

      it "updates the hmrc_response.response value" do
        expect(hmrc_response.reload.response).to match_json_expression unknown_response
      end
    end

    context "and is paid four-weekly" do
      let(:applicant) { create(:applicant, first_name: "Jeremy", last_name: "Irons", national_insurance_number: "BB313661B", date_of_birth: "1966-06-06") }
      let(:additional_before_actions) { allow(application).to receive(:calculation_date).and_return(Date.new(2020, 12, 10)) }

      it "updates the hmrc_response.response value" do
        expect(hmrc_data[1]["individuals/matching/individual"]["firstName"]).to eq "Jeremy"
        expect(hmrc_data[2]["income/paye/paye"]["income"][0]["payFrequency"]).to eq "W4"
      end
    end

    context "and has multiple employments" do
      let(:applicant) { create(:applicant, first_name: "Ida", last_name: "Paisley", national_insurance_number: "OE726113A", date_of_birth: "1987-11-24") }
      let(:additional_before_actions) { allow(application).to receive(:calculation_date).and_return(Date.new(2020, 12, 10)) }

      it "updates the hmrc_response.response value" do
        expect(hmrc_data[1]["individuals/matching/individual"]["firstName"]).to eq "Ida"
        expect(hmrc_data[2]["income/paye/paye"]["income"][0]["payFrequency"]).to eq "W4"
        expect(hmrc_data[2]["income/paye/paye"]["income"][1]["payFrequency"]).to eq "W1"
        expect(hmrc_data[16]["employments/paye/employments"].size).to eq 4
      end
    end

    context "and receives tax credits" do
      let(:applicant) { create(:applicant, first_name: "Oakley", last_name: "Weller", national_insurance_number: "AB476107D", date_of_birth: "1988-08-08") }
      let(:additional_before_actions) { allow(application).to receive(:calculation_date).and_return(Date.new(2021, 12, 17)) }

      it "updates the hmrc_response.response value" do
        expect(hmrc_data[1]["individuals/matching/individual"]["firstName"]).to eq "Oakley"
        expect(hmrc_data[17]["benefits_and_credits/working_tax_credit/applications"][0]["awards"][0]["totalEntitlement"]).not_to be_nil
      end
    end
  end

  context "when the mock response owner is set to a partner that is available to the mock response service" do
    let(:applicant) { create(:applicant, first_name: "Langley", last_name: "Yorke", national_insurance_number: "MN212451D", date_of_birth: "1992-07-22") }
    let(:partner) { create(:partner, first_name: "Ida", last_name: "Paisley", national_insurance_number: "OE726113A", date_of_birth: "1987-11-24") }
    let(:application) { create(:legal_aid_application, applicant:, partner:) }
    let(:owner) { partner }

    it "returns data for the partner, _not_ the applicant" do
      expect(hmrc_data[1]["individuals/matching/individual"]["firstName"]).to eq "Ida"
    end
  end
end
