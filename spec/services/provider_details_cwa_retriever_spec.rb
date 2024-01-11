require "rails_helper"

RSpec.describe ProviderDetailsCWARetriever, :vcr do
  describe ".call" do
    subject(:call) { described_class.call(username) }

    let(:username) { "dummy_user" }

    context "with a non existent user" do
      it "returns an error" do
        expect { call }.to raise_error(ProviderDetailsCWARetriever::ApiRecordNotFoundError)
      end
    end
  end
end
