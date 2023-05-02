require "rails_helper"

RSpec.describe CFECivil::Components::Employments do
  subject(:call) { described_class.call(legal_aid_application) }

  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }

  context "when the applicant is not employed" do
    before { create(:applicant, :not_employed) }

    it "renders the expected, empty hash" do
      expect(call).to eq({}.to_json)
    end
  end

  context "when the applicant is employed but has no PAYE data" do
    before do
      create(:applicant, :employed)
      create(:employment, legal_aid_application:)
    end

    it "renders the expected, empty hash" do
      expect(call).to eq({}.to_json)
    end
  end

  context "when the applicant is employed" do
    before do
      create(:applicant, :employed)
      create(:employment, :example1_usecase1, legal_aid_application:)
    end

    it "renders the expected JSON" do
      expect(call).to eq({
        employment_income: [
          {
            name: "Job 788",
            client_id: "12345678-1234-1234-1234-123456789abc",
            payments: [
              {
                client_id: "20211128-0000-0000-0000-123456789abc",
                date: "2021-11-28",
                gross: 1868.98,
                benefits_in_kind: 0.0,
                tax: -161.8,
                national_insurance: -128.64,
                net_employment_income: 1578.54,
              },
              {
                client_id: "20211028-0000-0000-0000-123456789abc",
                date: "2021-10-28",
                gross: 1868.98,
                benefits_in_kind: 0.0,
                tax: -111.0,
                national_insurance: -128.64,
                net_employment_income: 1629.34,
              },
              {
                client_id: "20210928-0000-0000-0000-123456789abc",
                date: "2021-09-28",
                gross: 2492.61,
                benefits_in_kind: 0.0,
                tax: -286.6,
                national_insurance: -203.47,
                net_employment_income: 2002.54,
              },
              {
                client_id: "20210828-0000-0000-0000-123456789abc",
                date: "2021-08-28",
                gross: 2345.29,
                benefits_in_kind: 0.0,
                tax: -257.2,
                national_insurance: -185.79,
                net_employment_income: 1902.3,
              },
            ],
          },
        ],
      }.to_json)
    end
  end
end
