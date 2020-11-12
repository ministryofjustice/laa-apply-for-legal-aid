require 'rails_helper'

module CCMS
  module Parsers
    RSpec.describe CaseAddStatusResponseParser do
      context 'successful response' do
        describe '#success?' do
          let(:response_xml) { ccms_data_from_file 'case_add_status_response.xml' }
          let(:expected_tx_id) { '20190301030405123456' }

          it 'extracts the status' do
            parser = described_class.new(expected_tx_id, response_xml)
            expect(parser.success?).to eq true
          end

          it 'raises if the transaction_request_ids dont match' do
            expect {
              parser = described_class.new(Faker::Number.number(digits: 20), response_xml)
              parser.success?
            }.to raise_error CCMS::CCMSError, "Invalid transaction request id #{expected_tx_id}"
          end

          describe '#success' do
            it 'returns true' do
              parser = described_class.new(expected_tx_id, response_xml)
              parser.success?
              expect(parser.success).to be true
            end
          end

          describe '#message' do
            it 'returns the status plus any status text' do
              parser = described_class.new(expected_tx_id, response_xml)
              parser.success?
              expect(parser.message).to eq 'Success: Case successfully created.'
            end
          end
        end
      end

      describe '#success? exception' do
        let(:response_xml) { ccms_data_from_file 'case_add_status_response.xml' }
        let(:expected_tx_id) { '20190301030405123456' }

        it 'raises if the transaction_request_ids dont match' do
          expect {
            parser = described_class.new(Faker::Number.number(digits: 20), response_xml)
            parser.success?
          }.to raise_error CCMS::CCMSError, "Invalid transaction request id #{expected_tx_id}"
        end
      end
    end
  end
end
