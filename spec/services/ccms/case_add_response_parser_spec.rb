require 'rails_helper'

module CCMS
  RSpec.describe CaseAddResponseParser do
    describe '#parse' do
      let(:response_xml) { File.read("#{File.dirname(__FILE__)}/data/add_case_response.xml") }

      it 'extracts the status' do
        parser = described_class.new('20190301030405123456', response_xml)
        expect(parser.parse).to eq 'Success'
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
