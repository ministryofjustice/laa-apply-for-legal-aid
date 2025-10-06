require "rails_helper"
RSpec.describe CCMSUser::Connection do
  subject(:connection) { described_class.new }

  it { is_expected.to respond_to :get }

  describe "#get" do
    subject(:get) { connection.get(uri) }

    let(:uri) { "/" }

    before { allow(connection.conn).to receive(:get) }

    it "delegated to adapter connection" do
      get
      expect(connection.conn).to have_received(:get)
    end
  end
end
