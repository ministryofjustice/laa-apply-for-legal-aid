require "rails_helper"
RSpec.describe BankHolidayRetriever do
  subject(:instance) { described_class.new }

  let(:group) { "england-and-wales" }

  around do |example|
    VCR.turned_off { example.run }
  end

  before do
    stub_bankholiday_success
  end

  describe ".dates" do
    it "returns same as instance dates for group" do
      expect(described_class.dates).to eq(instance.dates(group))
    end

    context "when the call fails with a 404, not found" do
      before { stub_bankholiday_not_found }

      it "raises error" do
        expect { described_class.dates }.to raise_error(described_class::UnsuccessfulRetrievalError, /Retrieval Failed: 404/)
      end
    end

    context "when the call fails with a 422, unprocessible entity" do
      before { stub_bankholiday_unprocessable }

      it "raises error" do
        expect { described_class.dates }.to raise_error(described_class::UnsuccessfulRetrievalError, /Retrieval Failed: 422/)
      end
    end

    context "when the call encounters a connection error" do
      before do
        conn = instance_double(Faraday::Connection)
        allow(Faraday).to receive(:new).and_return(conn)
        allow(conn).to receive(:get).and_raise(OpenSSL::SSL::SSLError.new("SSL_connect returned=1 errno=0 state=error: unexpected eof while reading"))
      end

      it "logs the error" do
        allow(Rails.logger).to receive(:error)
        instance.dates(group)
      rescue OpenSSL::SSL::SSLError
        expect(Rails.logger).to have_received(:error).with(/BankHolidayRetriever error: OpenSSL::SSL::SSLError, SSL_connect returned=1 errno=0 state=error: unexpected eof while reading/)
      end

      it "raises the error" do
        expect { instance.dates(group) }.to raise_error(OpenSSL::SSL::SSLError, /SSL_connect returned=1 errno=0 state=error: unexpected eof while reading/)
      end
    end
  end

  describe "#data" do
    it "is a hash" do
      expect(instance.data).to be_a(Hash)
    end

    it "has the expected basic structure" do
      expect(instance.data.keys).to include(group)
    end
  end

  describe "#dates" do
    let(:dates) { instance.dates(group) }

    it "is an array" do
      expect(dates).to be_a(Array)
    end

    it "contains date strings" do
      expect(Date.parse(dates.first)).to be_a(Date)
    end
  end
end
