require "rails_helper"
RSpec.describe CCMSUser::Connection do
  subject(:connection) { described_class.instance }

  describe "singleton" do
    it ".instance" do
      expect(connection).to eql described_class.instance
    end

    it ".new raises error" do
      expect { described_class.new }.to raise_error NoMethodError
    end
  end

  it { is_expected.to respond_to :get }

  describe "#get" do
    subject(:get) { described_class.instance.get(uri) }

    let(:uri) { "/" }

    before { allow(described_class.instance.conn).to receive(:get) }

    it "delegated to adapter connection" do
      get
      expect(described_class.instance.conn).to have_received(:get)
    end
  end
end
