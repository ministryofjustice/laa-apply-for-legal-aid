require "rails_helper"

RSpec.describe Datastore::MockDatastoreToken do
  subject(:instance) { described_class.new }

  describe "#access_token" do
    before do
      allow(Rails.configuration.x.data_access_api).to receive(:mock_bearer_token).and_return("mock_bearer_token")
    end

    it "returns mock access token from configuration" do
      expect(instance.access_token).to eq("mock_bearer_token")
    end
  end
end
