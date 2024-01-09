require "rails_helper"

RSpec.describe ProviderDetailsCWARetriever, :vcr do
  describe ".call" do
    subject(:call) { described_class.call(username) }

    let(:username) { "dummy_user" }

    context "with a non existent user" do
      it "returns an empty string" do
        expect(call).to eq ""
      end
    end
  end
end
