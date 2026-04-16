require "rails_helper"
require Rails.root.join("spec/services/pda/provider_details_request_stubs")

RSpec.describe PDA::OfficesAddressesRetriever do
  let(:office_codes) { %w[4A497U 4A497V] }

  describe "#call" do
    subject(:call) { described_class.new(office_codes).call }

    context "when the API call is successful" do
      before do
        stub_provider_addresses_for(office_codes)
      end

      it "returns an OfficeAddressStruct with the expected data" do
        result = call

        expect(result)
          .to be_a(Array)
          .and all(be_a(PDA::OfficesAddressesRetriever::OfficeAddressStruct))

        expect(result.first).to have_attributes(
          code: office_codes.first,
          # firm_name: "Test firm",
          address_line_one: "Office 1 address line 1",
          address_line_two: "Office 1 address line 2",
          address_line_three: nil,
          address_line_four: nil,
          city: "Test city 1",
          county: nil,
          post_code: "TE5T1NG",
        )

        expect(result.second).to have_attributes(
          code: office_codes.second,
          # firm_name: "Test firm",
          address_line_one: "Office 2 address line 1",
          address_line_two: "Office 2 address line 2",
          address_line_three: nil,
          address_line_four: nil,
          city: "Test city 2",
          county: nil,
          post_code: "TE5T2NG",
        )
      end
    end
  end
end
