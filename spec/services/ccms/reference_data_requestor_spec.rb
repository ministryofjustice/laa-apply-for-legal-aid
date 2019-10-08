require 'rails_helper'

module CCMS
  RSpec.describe ReferenceDataRequestor do
    let(:expected_xml) { ccms_data_from_file 'reference_data_request.xml' }
    let(:expected_tx_id) { '20190101121530123456' }
    let(:requestor) { described_class.new('my_login') }

    describe 'XML request' do
      include_context 'ccms soa configuration'

      it 'generates the expected XML' do
        allow(requestor).to receive(:transaction_request_id).and_return(expected_tx_id)
        expect(requestor.formatted_xml).to eq expected_xml.chomp
      end
    end

    describe '#transaction_request_id' do
      it 'returns the id based on current time' do
        Timecop.freeze(2019, 1, 1, 12, 15, 30.123456) do
          expect(requestor.transaction_request_id).to start_with expected_tx_id
        end
      end
    end

    describe '#call' do
      let(:soap_client_double) { Savon.client(env_namespace: :soap, wsdl: requestor.__send__(:wsdl_location)) }
      let(:expected_soap_operation) { :process }
      let(:expected_xml) { requestor.__send__(:request_xml) }

      before do
        Timecop.freeze
        expect(requestor).to receive(:soap_client).and_return(soap_client_double)
      end

      it 'calls the savon soap client' do
        expect(soap_client_double).to receive(:call).with(expected_soap_operation, xml: expected_xml)
        requestor.call
      end
    end
  end
end
