require "rails_helper"
require Rails.root.join("spec/services/datastore/data_access_api_stubs")

RSpec.describe Datastore::Connection do
  subject(:instance) { described_class.new }

  before do
    stub_successful_refresh_token_request
  end

  it { is_expected.to respond_to :post }

  describe "#post" do
    subject(:post) { instance.post(uri) }

    let(:uri) { "/" }

    before { allow(instance.connection).to receive(:post) }

    it "delegated to adapter connection" do
      post
      expect(instance.connection).to have_received(:post)
    end
  end
end
