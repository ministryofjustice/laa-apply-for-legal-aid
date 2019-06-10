require 'rails_helper'

module CCMS
  RSpec.describe ApplicantSearchRequestor do
    let(:expected_xml) { ccms_data_from_file 'applicant_search_request.xml' }
    let(:expected_tx_id) { '20190101121530123456' }
    let(:applicant) do
      create(:applicant,
             first_name: 'lenovo',
             last_name: 'hurlock',
             date_of_birth: Date.new(1969, 1, 1),
             national_insurance_number: 'YS327299B')
    end
    let(:requestor) { described_class.new(applicant) }

    describe 'XML request' do
      it 'generates the expected XML' do
        with_modified_env(modified_environment_vars) do
          allow(requestor).to receive(:transaction_request_id).and_return(expected_tx_id)
          expect(requestor.formatted_xml).to eq expected_xml.chomp
        end
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
