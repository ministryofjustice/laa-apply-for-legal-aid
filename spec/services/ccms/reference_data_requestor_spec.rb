require 'rails_helper'

module CCMS

  RSpec.describe ReferenceDataRequestor do

    describe 'XML request' do
      it 'generates the expected XML' do
        with_modified_env(modified_environment_vars) do
          requestor = described_class.new
          allow(requestor).to receive(:transaction_request_id).and_return('20190101121530123456')
          expect(requestor.formatted_xml).to eq expected_xml.chomp
        end
      end
    end

    describe '#transaction_request_id' do
      it 'returns the id based on current time' do
        Timecop.freeze(2019, 1, 2, 3, 4, 5.123456) do
          requestor = described_class.new
          expect(requestor.transaction_request_id).to eq '20190102030405123456'
        end
      end
    end





    def modified_environment_vars
      {
        'SOAP_CLIENT_USERNAME' => 'my_soap_client_username',
        'SOAP_CLIENT_PASSWORD' => 'xxxxx',
        'USER_LOGIN' => 'my_login',
        'USER_ROLE' => 'my_role'
      }
    end

    def expected_xml
      File.read("#{File.dirname(__FILE__)}/data/expected_get_reference_data_request.xml")
    end

  end
end



# SOAP_CLIENT_USERNAME = ENV['SOAP_CLIENT_USERNAME']
#     SOAP_CLIENT_PASSWORD_TYPE = ENV['SOAP_CLIENT_PASSWORD_TYPE']
#     SOAP_CLIENT_PASSWORD = ENV['SOAP_CLIENT_PASSWORD']
#     USER_LOGIN = ENV['USER_LOGIN']
#     USER_ROLE = ENV['USER_ROLE']
