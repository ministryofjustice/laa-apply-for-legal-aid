require "rails_helper"

RSpec.describe PDA::ContractsCreator do
  describe ".call" do
    subject(:call) { described_class.call(office.code) }

    before do
      stub_request(:get, "#{Rails.configuration.x.pda.url}/provider-offices/#{office_code}/office-contract-details")
        .to_return(body:, status:)
    end

    let(:office) { create(:office, code: office_code) }
    let(:office_code) { "4S404O" }

    context "when the office has valid contracts" do
      let(:office_code) { "4A497U" }
      let(:status) { 200 }
      let(:body) do
        {
          firm: {
            firmId: 1639,
            firmNumber: "1639",
            ccmsFirmId: 19_148,
            firmName: "DAVID GRAY LLP",
          },
          office: {
            firmOfficeId: 1234,
            ccmsFirmOfficeId: 123_456,
            firmOfficeCode: "4A497U",
            officeName: "4A497U,OLD COUNTY COURT",
            officeCodeAlt: "DAVID GRAY LLP",
          },
          contracts: [
            {
              categoryOfLaw: "MAT",
              subCategoryLaw: "Not Applicable",
              authorisationType: "Schedule",
              newMatters: "Yes",
              contractualDevolvedPowers: "Yes - Excluding JR Proceedings",
              remainderAuthorisation: "Yes",
            },
            {
              categoryOfLaw: "MSC",
              subCategoryLaw: "Not Applicable",
              authorisationType: "Schedule",
              newMatters: "Yes",
              contractualDevolvedPowers: "Yes - Excluding JR Proceedings",
              remainderAuthorisation: "Yes",
            },
            {
              categoryOfLaw: "PCW",
              subCategoryLaw: "Not Applicable",
              authorisationType: "Schedule",
              newMatters: "Yes",
              contractualDevolvedPowers: "No",
              remainderAuthorisation: "Yes",
            },
          ],
        }.to_json
      end

      it "associates the contracts with the correct office" do
        expect { call }.to change { office.contracts.count }.from(0).to(3)
      end

      it "creates the contracts with the correct category of law" do
        call
        expect(office.contracts.pluck(:category_of_law)).to contain_exactly("MAT", "MSC", "PCW")
      end
    end

    context "when the office does not have valid contracts" do
      let(:status) { 204 }
      let(:body) { "" }

      it "does not create any contracts" do
        call
        expect(office.contracts.count).to eq(0)
      end
    end

    context "when there is an error calling the api" do
      let(:body) { "An error has occurred" }
      let(:status) { 500 }

      it "raises ApiError" do
        expect { call }.to raise_error(PDA::ContractsCreator::ApiError, "API Call Failed: (500) An error has occurred")
      end
    end
  end
end
