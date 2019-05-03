require 'rails_helper'

module CCMS
  RSpec.describe ApplicantAddStatusResponseParser do
    describe '#parse' do
      let(:response_xml) { ccms_data_from_file 'applicant_add_status_response.xml' }
      let(:expected_tx_id) { '20190301030405123456' }

      it 'extracts the status free text' do
        parser = described_class.new(expected_tx_id, response_xml)
        expect(parser.parse).to eq 'User Authentication complete.'
      end

      it 'raises if the transaction_request_ids dont match' do
        expect {
          parser = described_class.new(Faker::Number.number(20), response_xml)
          parser.parse
        }.to raise_error RuntimeError, 'Invalid transaction request id'
      end
    end
  end
end
