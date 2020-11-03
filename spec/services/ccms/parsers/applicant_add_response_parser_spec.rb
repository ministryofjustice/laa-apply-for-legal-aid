require 'rails_helper'

module CCMS
  module Parsers
    RSpec.describe ApplicantAddResponseParser do
      let(:expected_tx_id) { '20190301030405123456' }

      context 'successful response' do
        describe '#success?' do
          let(:response_xml) { ccms_data_from_file 'applicant_add_response_success.xml' }

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
              expect(parser.message).to eq 'Success: '
            end
          end
        end
      end

      context 'unsuccessful response' do
        let(:response_xml) { ccms_data_from_file 'applicant_add_response_failure.xml' }

        subject { described_class.new(expected_tx_id, response_xml) }

        describe '#success?' do
          it 'is false' do
            expect(subject.success?).to be false
          end
        end

        describe '#success' do
          it 'is false' do
            subject.success?
            expect(subject.success).to be false
          end
        end

        describe '#message' do
          it 'returns status concatenated with any free text' do
            subject.success?
            expect(subject.message).to eq 'Failed: '
          end
        end
      end

      context 'response with no status or exception' do
        let(:response_xml) { ccms_data_from_file 'applicant_add_response_no_status.xml' }
        describe '#success?' do
          it 'raises' do
            parser = described_class.new(expected_tx_id, response_xml)
            expect { parser.success? }.to raise_error CCMS::CCMSError, 'Unable to find status code or exception in response'
          end
        end
      end

      context 'wrong transaction id' do
        let(:expected_tx_id) { '88880301030405123456' }
        let(:response_xml) { ccms_data_from_file 'applicant_add_response_success.xml' }
        it 'raises' do
          parser = described_class.new(expected_tx_id, response_xml)
          expect { parser.success? }.to raise_error CCMS::CCMSError, 'Invalid transaction request id 20190301030405123456'
        end
      end
    end
  end
end
