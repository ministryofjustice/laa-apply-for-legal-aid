require "rails_helper"

RSpec.describe PDA::ProviderDetailsRetriever, :vcr do
  describe ".call" do
    subject(:call) { described_class.call(username) }

    let(:username) { "dummy_user" }

    context "with a non existent user" do
      it "returns an error" do
        expect { call }.to raise_error(PDA::ProviderDetailsRetriever::ApiRecordNotFoundError)
      end
    end

    context "with an existing user" do
      let(:username) { "DT_SCRIPT_USER1" }

      it "returns provider details" do
        result = call
        expect(result.contact_id).to eq 0
        expect(result.firm_id).to eq 10_835_831
        expect(result.firm_name).to eq "DT SCRIPT PROVIDER 1"
        expect(result.provider_offices.first.code).to eq "2Q242F"
        expect(result.firm_offices.first.code).to eq "2Q242F"
      end
    end

    context "when there is an error calling the api" do
      before do
        stub_request(:get, "#{Rails.configuration.x.pda.url}/provider-users/#{username}/provider-offices")
          .to_return(body: "An error has occurred", status: 500)
      end

      it "raises ApiError" do
        expect {
          call
        }.to raise_error(PDA::ProviderDetailsRetriever::ApiError, "API Call Failed: (500) An error has occurred")
      end
    end

    context "when api returns no content" do
      before do
        stub_request(:get, "#{Rails.configuration.x.pda.url}/provider-users/#{username}/provider-offices")
          .to_return(body: nil, status: 204)
      end

      it "raises ApiError" do
        expect {
          call
        }.to raise_error(PDA::ProviderDetailsRetriever::ApiRecordNotFoundError, %r{Retrieval Failed: \(204\)})
      end
    end
  end
end
