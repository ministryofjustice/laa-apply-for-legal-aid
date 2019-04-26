require 'rails_helper'

module CCMS
  RSpec.describe ApplicantSearchResponseParser do
    describe '#parse' do
      let(:response_xml) { File.read("#{File.dirname(__FILE__)}/data/client_search_response.xml") }

      it 'extracts the number of records fetched' do
        parser = described_class.new('20190301030405123456', response_xml)
        expect(parser.parse).to eq '0'
      end

      it 'raises if the transaction_request_ids dont match' do
        expect {
          parser = described_class.new('20190301030405987654', response_xml)
          parser.parse
        }.to raise_error RuntimeError, 'Invalid transaction request id'
      end
    end
  end
end
