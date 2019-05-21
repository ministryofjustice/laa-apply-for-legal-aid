require 'rails_helper'

module CCMS
  RSpec.describe ApplicantAddRequestor do
    let(:expected_xml) { ccms_data_from_file 'applicant_add_request.xml' }
    let(:expected_tx_id) { '20190101121530123456' }

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

    describe 'wsdl_location' do
      it 'points to correct location' do
        expect(requestor.send(:wsdl_location)).to match('app/services/ccms/wsdls/ClientProxyServiceWsdl.xml')
      end
    end
  end
end
