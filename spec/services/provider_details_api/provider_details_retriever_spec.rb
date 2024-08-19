require "rails_helper"

RSpec.describe ProviderDetailsAPI::ProviderDetailsRetriever, :vcr do
  describe ".call" do
    subject(:call) { described_class.call(username) }

    let(:username) { "dummy_user" }

    context "with a non existent user" do
      it "returns an error" do
        expect { call }.to raise_error(ProviderDetailsAPI::ProviderDetailsRetriever::ApiRecordNotFoundError)
      end
    end

    context "with an existing user" do
      let(:username) { "DT_SCRIPT_USER1" }

      it "returns provider details" do
        response = call
        expect(response.contact_id).to eq 0
        expect(response.firm_id).to eq 0
        expect(response.firm_name).to eq "DT SCRIPT PROVIDER 1"
        expect(response.offices.first.code).to eq "2Q242F"
      end
    end
  end
end
