require 'rails_helper'

module CCMS
  RSpec.describe ApplicantAddStatusResponseParser do
    let(:response_xml) { ccms_data_from_file 'applicant_add_status_response.xml' }
    let(:expected_tx_id) { '20190301030405123456' }

    describe '#parse' do
      it 'extracts the status free text' do
        parser = described_class.new(expected_tx_id, response_xml)
        parser.parse
        expect(parser.status_free_text).to eq 'Party Successfully Created.'
      end

      it 'raises if the transaction_request_ids dont match' do
        expect {
          parser = described_class.new(Faker::Number.number(20), response_xml)
          parser.parse
        }.to raise_error CcmsError, 'Invalid transaction request id'
      end
    end

    describe '#success' do
      it 'returns true if extracted_status_free_text = "Party Successfully Created."' do
        parser = described_class.new(expected_tx_id, response_xml)
        parser.parse
        expect(parser.success?).to be true
      end
    end
  end
end
