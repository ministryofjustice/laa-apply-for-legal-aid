require 'rails_helper'

module CCMS
  RSpec.describe ApplicantAddStatusResponseParser do
    let(:response_xml) { ccms_data_from_file 'applicant_add_status_response.xml' }
    let(:expected_tx_id) { '20190301030405123456' }
    let(:expected_applicant_ccms_reference) { '20910584' }

    describe '#success?' do
      it 'raises if the transaction_request_ids dont match' do
        expect {
          parser = described_class.new(Faker::Number.number(20), response_xml)
          parser.success?
        }.to raise_error CcmsError, 'Invalid transaction request id'
      end

      it 'returns true if extracted_status_free_text = "Party Successfully Created."' do
        parser = described_class.new(expected_tx_id, response_xml)
        expect(parser.success?).to be true
      end
    end

    describe '#applicant_ccms_reference' do
      it 'returns the applicant_ccms_reference' do
        parser = described_class.new(expected_tx_id, response_xml)
        expect(parser.applicant_ccms_reference).to eq expected_applicant_ccms_reference
      end
    end
  end
end
