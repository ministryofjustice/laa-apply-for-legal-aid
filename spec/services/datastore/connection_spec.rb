require "rails_helper"
RSpec.describe Datastore::Connection do
  subject(:instance) { described_class.new }

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
