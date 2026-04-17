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
          .and all(be_a(PDA::OfficeAddressStruct))
      end
    end
  end
end
