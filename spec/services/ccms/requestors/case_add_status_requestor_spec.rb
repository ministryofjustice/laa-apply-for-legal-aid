require 'rails_helper'

module CCMS
  module Requestors
    RSpec.describe CaseAddStatusRequestor do
      let(:expected_xml) { ccms_data_from_file 'case_add_status_request.xml' }
      let(:expected_tx_id) { '20190101121530000000' }
      let(:requestor) { described_class.new(expected_tx_id, 'my_login') }

      describe 'XML request' do
        include_context 'ccms soa configuration'

        it 'generates the expected XML' do
          allow(requestor).to receive(:transaction_request_id).and_return(expected_tx_id)
          expect(requestor.formatted_xml).to be_soap_envelope_with(
            command: 'ns2:CaseAddUpdtStatusRQ',
            transaction_id: expected_tx_id
          )
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
        let(:expected_soap_operation) { :get_case_txn_status }
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
