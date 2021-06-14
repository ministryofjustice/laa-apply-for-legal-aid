require 'rails_helper'

module CCMS
  module Requestors
    RSpec.describe DocumentUploadRequestor do
      let(:expected_xml) { ccms_data_from_file 'document_upload_request.xml' }
      let(:expected_tx_id) { '20190101121530000000' }
      let(:case_ccms_reference) { '1234567890' }
      let(:document_id) { '4420073' }
      let(:document_encoded_base64) { 'JVBERi0xLjUNCiW1tbW1DQoxIDAgb2JqDQo8PC9UeXBlL0NhdGFsb2cvUGFnZXMgMiA' }
      let(:requestor) { described_class.new(case_ccms_reference, document_id, document_encoded_base64, 'my_login') }

      describe 'XML request' do
        context 'when sent a normal document' do
          include_context 'ccms soa configuration'

          it 'generates the expected XML' do
            allow(requestor).to receive(:transaction_request_id).and_return(expected_tx_id)
            expect(requestor.formatted_xml).to be_soap_envelope_with(
              command: 'ns2:DocumentUploadRQ',
              transaction_id: expected_tx_id,
              matching: %w[
                <ns4:DocumentType>ADMIN1</ns4:DocumentType>
                <ns4:FileExtension>pdf</ns4:FileExtension>
              ]
            )
          end
        end

        context 'when sent a gateway evidence document' do
          let(:requestor) { described_class.new(case_ccms_reference, document_id, document_encoded_base64, 'my_login', 'gateway_evidence_pdf') }

          include_context 'ccms soa configuration'

          it 'generates the expected XML' do
            allow(requestor).to receive(:transaction_request_id).and_return(expected_tx_id)
            expect(requestor.formatted_xml).to be_soap_envelope_with(
              command: 'ns2:DocumentUploadRQ',
              transaction_id: expected_tx_id,
              matching: %w[
                <ns4:DocumentType>STATE</ns4:DocumentType>
                <ns4:FileExtension>pdf</ns4:FileExtension>
              ]
            )
          end
        end

        context 'when sent a bank_transaction_report' do
          let(:requestor) { described_class.new(case_ccms_reference, document_id, document_encoded_base64, 'my_login', 'bank_transaction_report') }

          include_context 'ccms soa configuration'

          it 'generates the expected XML' do
            allow(requestor).to receive(:transaction_request_id).and_return(expected_tx_id)
            expect(requestor.formatted_xml).to be_soap_envelope_with(
              command: 'ns2:DocumentUploadRQ',
              transaction_id: expected_tx_id,
              matching: %w[
                <ns4:DocumentType>BSTMT</ns4:DocumentType>
                <ns4:FileExtension>csv</ns4:FileExtension>
              ]
            )
          end
        end
      end

      describe '#transaction_request_id' do
        it 'returns the id based on current time' do
          travel_to Time.zone.local(2019, 1, 1, 12, 15, 30) do
            expect(requestor.transaction_request_id).to start_with expected_tx_id
          end
        end
      end

      describe '#call' do
        let(:soap_client_double) { Savon.client(env_namespace: :soap, wsdl: requestor.__send__(:wsdl_location)) }
        let(:expected_soap_operation) { :upload_document }
        let(:expected_xml) { requestor.__send__(:request_xml) }

        before do
          expect(requestor).to receive(:soap_client).and_return(soap_client_double)
        end

        it 'calls the savon soap client' do
          expect(soap_client_double).to receive(:call).with(expected_soap_operation, xml: expected_xml)
          requestor.call
        end
      end
    end
  end
end
