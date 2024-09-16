require "rails_helper"

RSpec.describe PDA::CurrentContracts do
  describe ".call" do
    subject(:call) { described_class.call(office_code) }

    before do
      stub_request(:get, "#{Rails.configuration.x.pda.url}/provider-office/#{office_code}/office-contract-details")
        .to_return(body:, status:)
    end

    let(:office) { create(:office, code: office_code) }
    let(:office_code) { "4S404O" }

    context "when the office_code is valid" do
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

      it "records the expected value" do
        expect { call }.to change(TempContractData, :count).from(0).to(1)
      end
    end

    context "when the office_code is invalid" do
      let(:status) { 204 }
      let(:body) { "" }

      it "records the expected value" do
        expect(TempContractData).to receive(:create!).with({ success: false, office_code: "4S404O", response: { error: "Retrieval Failed: (204) " } })
        call
      end
    end

    context "when there is an error calling the api" do
      let(:body) { "An error has occurred" }
      let(:status) { 500 }

      it "raises ApiError" do
        expect(TempContractData).to receive(:create!).with({ success: false, office_code: "4S404O", response: { error: "API Call Failed: (500) An error has occurred" } })
        call
      end
    end
  end
end
