require 'rails_helper'

module CCMS
  module Parsers
    RSpec.describe DocumentUploadResponseParser do
      describe '#success?' do
        let(:response_xml) { ccms_data_from_file 'document_upload_response.xml' }
        let(:expected_tx_id) { '20190301030405123456' }

        it 'extracts the status' do
          parser = described_class.new(expected_tx_id, response_xml)
          expect(parser.success?).to eq true
        end
      end
    end
  end
end
