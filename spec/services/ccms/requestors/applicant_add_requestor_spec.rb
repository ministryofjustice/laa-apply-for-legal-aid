require 'rails_helper'

module CCMS
  module Requestors
    RSpec.describe ApplicantAddRequestor do
      let(:expected_xml) { ccms_data_from_file 'applicant_add_request.xml' }
      let(:expected_tx_id) { '20190101121530000000' }

      let(:address) do
        create(:address,
               address_line_one: '102',
               address_line_two: 'Petty France',
               city: 'London',
               postcode: 'SW1H9AJ')
      end

      let(:applicant) do
        create(:applicant,
               address: address,
               first_name: 'lenovo',
               last_name: 'Hurlock',
               date_of_birth: Date.new(1969, 1, 1))
      end

      let(:requestor) { described_class.new(applicant, 'my_login') }

      describe 'XML request' do
        include_context 'ccms soa configuration'

        it 'generates the expected XML' do
          allow(requestor).to receive(:transaction_request_id).and_return(expected_tx_id)
          expect(requestor.formatted_xml).to be_soap_envelope_with(
            command: 'ns2:ClientAddRQ',
            transaction_id: expected_tx_id,
            matching: [
              "<ns4:AddressLine1>#{applicant.address.address_line_one} #{applicant.address.address_line_two}</ns4:AddressLine1>",
              "<ns4:City>#{applicant.address.city}</ns4:City>"
            ]
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

      describe 'wsdl_location' do
        it 'points to correct location' do
          expect(requestor.__send__(:wsdl_location)).to match('app/services/ccms/wsdls/ClientProxyServiceWsdl.xml')
        end
      end

      describe '#call' do
        let(:soap_client_double) { Savon.client(env_namespace: :soap, wsdl: requestor.__send__(:wsdl_location)) }
        let(:expected_soap_operation) { :create_client }
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
