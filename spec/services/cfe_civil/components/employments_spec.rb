require "rails_helper"

RSpec.describe CFECivil::Components::Employments do
  subject(:call) { described_class.call(legal_aid_application) }

  let(:legal_aid_application) { create(:legal_aid_application) }

  context "when the applicant is not employed" do
    before { create(:applicant, :not_employed, legal_aid_application:) }

    it "renders the expected, empty hash" do
      expect(call).to eq({}.to_json)
    end
  end

  context "when the applicant is employed but has no PAYE data" do
    before do
      applicant = create(:applicant, :employed, legal_aid_application:)
      create(:employment, legal_aid_application:, owner_id: applicant.id, owner_type: applicant.class)
    end

    it "renders the expected, empty hash" do
      expect(call).to eq({}.to_json)
    end
  end

  context "when the applicant and partner are employed" do
    before do
      applicant = create(:applicant, :employed, legal_aid_application:)
      partner = create(:partner, :employed, legal_aid_application:)
      create(:employment, :example1_usecase1, legal_aid_application:, owner_id: applicant.id, owner_type: applicant.class)
      create(:employment, :example2_usecase1, legal_aid_application:, owner_id: partner.id, owner_type: partner.class)
    end

    context "and no owner type is specified" do
      it "renders the expected JSON for just the client" do
        result = JSON.parse(call, symbolize_names: true)

        expect(result).to match hash_including({
          employment_income: [
            {
              name: "Job 788",
              client_id: kind_of(String),
              payments: [
                {
                  client_id: kind_of(String),
                  date: "2021-11-28",
                  gross: 1868.98,
                  benefits_in_kind: 0.0,
                  tax: -161.8,
                  national_insurance: -128.64,
                  net_employment_income: 1578.54,
                },
                {
                  client_id: kind_of(String),
                  date: "2021-10-28",
                  gross: 1868.98,
                  benefits_in_kind: 0.0,
                  tax: -111.0,
                  national_insurance: -128.64,
                  net_employment_income: 1629.34,
                },
                {
                  client_id: kind_of(String),
                  date: "2021-09-28",
                  gross: 2492.61,
                  benefits_in_kind: 0.0,
                  tax: -286.6,
                  national_insurance: -203.47,
                  net_employment_income: 2002.54,
                },
                {
                  client_id: kind_of(String),
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
        })
      end
    end

    context "and partner is specified as owner type" do
      subject(:call) { described_class.call(legal_aid_application, "Partner") }

      it "renders the expected JSON for just the partner" do
        result = JSON.parse(call, symbolize_names: true)

        expect(result).to match hash_including({
          employments: [
            {
              name: "Job 877",
              client_id: kind_of(String),
              payments: [
                {
                  client_id: kind_of(String),
                  date: "2021-11-28",
                  gross: 1868.98,
                  benefits_in_kind: 0.0,
                  tax: -161.8,
                  national_insurance: -128.64,
                  net_employment_income: 1578.54,
                },
                {
                  client_id: kind_of(String),
                  date: "2021-10-28",
                  gross: 1868.98,
                  benefits_in_kind: 0.0,
                  tax: -111.0,
                  national_insurance: -128.64,
                  net_employment_income: 1629.34,
                },
                {
                  client_id: kind_of(String),
                  date: "2021-09-28",
                  gross: 2492.61,
                  benefits_in_kind: 0.0,
                  tax: -286.6,
                  national_insurance: -203.47,
                  net_employment_income: 2002.54,
                },
                {
                  client_id: kind_of(String),
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
        })
      end
    end
  end
end
