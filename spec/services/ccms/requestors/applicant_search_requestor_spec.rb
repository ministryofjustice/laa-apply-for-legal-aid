require 'rails_helper'

module CCMS
  module Requestors
    RSpec.describe ApplicantSearchRequestor do
      let(:expected_xml) { ccms_data_from_file 'applicant_search_request.xml' }
      let(:expected_tx_id) { '20190101121530000000' }
      let(:applicant) do
        create(:applicant,
               first_name: 'lenovo',
               last_name: 'hurlock',
               date_of_birth: Date.new(1969, 1, 1),
               national_insurance_number: 'YS327299B')
      end
      let(:requestor) { described_class.new(applicant, 'my_login') }

      describe 'XML request' do
        include_context 'ccms soa configuration'

        it 'generates the expected XML' do
          allow(requestor).to receive(:transaction_request_id).and_return(expected_tx_id)
          expect(requestor.formatted_xml).to be_soap_envelope_with(
            command: 'ns2:ClientInqRQ',
            transaction_id: expected_tx_id,
            matching: [
              "<ns5:Surname>#{applicant.last_name}</ns5:Surname>",
              "<ns5:FirstName>#{applicant.first_name}</ns5:FirstName>"
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

      describe '#call' do
        let(:soap_client_double) { Savon.client(env_namespace: :soap, wsdl: requestor.__send__(:wsdl_location)) }
        let(:expected_soap_operation) { :get_client_details }
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
