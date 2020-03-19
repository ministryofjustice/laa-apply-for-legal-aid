require 'rails_helper'

module CCMS
  module Parsers
    RSpec.describe DocumentIdResponseParser do
      let(:response_xml) { ccms_data_from_file 'document_id_response.xml' }
      let(:expected_tx_id) { '20190301030405123456' }
      let(:expected_document_id) { '4420073' }

      context 'success' do
        let(:response_xml) { ccms_data_from_file 'document_id_response.xml' }
        let(:parser) { described_class.new(expected_tx_id, response_xml) }

        describe '#document_id' do
          it 'extracts the document id' do
            parser = described_class.new(expected_tx_id, response_xml)
            expect(parser.document_id).to eq expected_document_id
          end
        end

        describe '#success' do
          it 'returns true' do
            parser = described_class.new(expected_tx_id, response_xml)
            parser.document_id
            expect(parser.success).to be true
          end
        end
      end

      context 'error' do
        let(:response_xml) { ccms_data_from_file 'document_id_response_failure.xml' }

        describe '#success' do
          it 'returns false' do
            parser = described_class.new(expected_tx_id, response_xml)
            parser.document_id
            expect(parser.success).to be false
          end
        end

        describe '#message' do
          it 'returns the status and message' do
            parser = described_class.new(expected_tx_id, response_xml)
            parser.document_id
            expect(parser.message).to eq 'Fail: Unable to allocate id'
          end
        end
      end
    end
  end
end
