require "rails_helper"

module CCMS
  module Requestors
    RSpec.describe ApplicantAddRequestor, :ccms do
      before { allow(Setting).to receive(:home_address?).and_return true }

      let(:expected_xml) { ccms_data_from_file "applicant_add_request.xml" }
      let(:expected_tx_id) { "20190101121530000000" }
      let(:last_name_at_birth) { nil }
      let(:address) do
        create(:address,
               address_line_one: "102 Petty France",
               address_line_two: "St James Park",
               county: "Westminster",
               city: "London",
               postcode: "SW1H9AJ")
      end

      let(:applicant) do
        create(:applicant,
               address:,
               first_name: "lenovo",
               last_name: "Hurlock",
               last_name_at_birth:,
               national_insurance_number: "QQ123456Q",
               date_of_birth: Date.new(1969, 1, 1),
               same_correspondence_and_home_address: true)
      end

      let(:requestor) { described_class.new(applicant, "my_login") }

      describe "XML request" do
        include_context "with ccms soa configuration"

        it "generates the expected XML" do
          allow(requestor).to receive(:transaction_request_id).and_return(expected_tx_id)
          expect(requestor.formatted_xml).to be_soap_envelope_with(
            command: "clientbim:ClientAddRQ",
            transaction_id: expected_tx_id,
            matching: [
              "<common:Surname>Hurlock</common:Surname>",
              "<common:SurnameAtBirth>Hurlock</common:SurnameAtBirth>",
              "<clientbio:NINumber>QQ123456Q</clientbio:NINumber>",
              "<common:AddressLine1>102 Petty France</common:AddressLine1>",
              "<common:AddressLine2>St James Park</common:AddressLine2>",
              "<common:City>London</common:City>",
              "<common:County>Westminster</common:County>",
              "<common:Country>GBR</common:Country>",
              "<common:PostalCode>SW1H 9AJ</common:PostalCode>",
            ],
          )
        end

        context "when the applicant has a surname_at_birth" do
          let(:last_name_at_birth) { "different" }

          it "generates the expected XML" do
            allow(requestor).to receive(:transaction_request_id).and_return(expected_tx_id)
            expect(requestor.formatted_xml).to be_soap_envelope_with(
              command: "clientbim:ClientAddRQ",
              transaction_id: expected_tx_id,
              matching: [
                "<common:Surname>Hurlock</common:Surname>",
                "<common:SurnameAtBirth>different</common:SurnameAtBirth>",
                "<clientbio:NINumber>QQ123456Q</clientbio:NINumber>",
                "<common:AddressLine1>102 Petty France</common:AddressLine1>",
                "<common:AddressLine2>St James Park</common:AddressLine2>",
                "<common:City>London</common:City>",
                "<common:County>Westminster</common:County>",
                "<common:Country>GBR</common:Country>",
                "<common:PostalCode>SW1H 9AJ</common:PostalCode>",
              ],
            )
          end
        end

        context "when the applicant has a different home address" do
          before do
            applicant.update!(same_correspondence_and_home_address: false,
                              addresses: [address, home_address])
          end

          let(:home_address) do
            create(:address,
                   :as_home_address,
                   address_line_one: "27 A Street",
                   address_line_two: nil,
                   county: "A county",
                   city: "The City",
                   postcode: "AB1 2CD")
          end

          it "generates the expected XML" do
            allow(requestor).to receive(:transaction_request_id).and_return(expected_tx_id)
            expect(requestor.formatted_xml).to be_soap_envelope_with(
              command: "clientbim:ClientAddRQ",
              transaction_id: expected_tx_id,
              matching: [
                "<common:Surname>Hurlock</common:Surname>",
                "<common:SurnameAtBirth>Hurlock</common:SurnameAtBirth>",
                "<clientbio:NINumber>QQ123456Q</clientbio:NINumber>",
                "<common:AddressLine1>27 A Street</common:AddressLine1>",
                "<common:AddressLine2/>",
                "<common:City>The City</common:City>",
                "<common:County>A county</common:County>",
                "<common:Country>GBR</common:Country>",
                "<common:PostalCode>AB1 2CD</common:PostalCode>",
              ],
            )
          end
        end

        context "when the applicant has no fixed residence" do
          before do
            applicant.update!(same_correspondence_and_home_address: false,
                              no_fixed_residence: true,
                              addresses: [])
          end

          it "generates the expected XML" do
            allow(requestor).to receive(:transaction_request_id).and_return(expected_tx_id)
            expect(requestor.formatted_xml).to be_soap_envelope_with(
              command: "clientbim:ClientAddRQ",
              transaction_id: expected_tx_id,
              matching: [
                "<common:Surname>Hurlock</common:Surname>",
                "<common:SurnameAtBirth>Hurlock</common:SurnameAtBirth>",
                "<clientbio:NINumber>QQ123456Q</clientbio:NINumber>",
                "<clientbio:NoFixedAbode>true</clientbio:NoFixedAbode>",
                "<clientbio:Address/>",
              ],
            )
          end
        end

        context "when the applicant has a surname containing special characters" do
          before do
            applicant.update!(last_name: "O’‘Hare")
          end

          it "generates the expected XML" do
            allow(requestor).to receive(:transaction_request_id).and_return(expected_tx_id)
            expect(requestor.formatted_xml).to be_soap_envelope_with(
              command: "clientbim:ClientAddRQ",
              transaction_id: expected_tx_id,
              matching: [
                "<common:Surname>O''Hare</common:Surname>",
                "<common:SurnameAtBirth>O''Hare</common:SurnameAtBirth>",
                "<clientbio:NINumber>QQ123456Q</clientbio:NINumber>",
                "<common:AddressLine1>102 Petty France</common:AddressLine1>",
                "<common:AddressLine2>St James Park</common:AddressLine2>",
                "<common:City>London</common:City>",
                "<common:County>Westminster</common:County>",
                "<common:Country>GBR</common:Country>",
                "<common:PostalCode>SW1H 9AJ</common:PostalCode>",
              ],
            )
          end
        end
      end

      describe "#transaction_request_id" do
        it "returns the id based on current time" do
          travel_to Time.zone.local(2019, 1, 1, 12, 15, 30) do
            expect(requestor.transaction_request_id).to start_with expected_tx_id
          end
        end
      end

      describe "wsdl_location" do
        it "points to correct location" do
          expect(requestor.__send__(:wsdl_location)).to match("app/services/ccms/wsdls/ClientProxyServiceWsdl.xml")
        end
      end

      describe "#call" do
        before do
          allow(Faraday::SoapCall).to receive(:new).and_return(soap_call)
          stub_request(:post, expected_url)
        end

        let(:soap_call) { instance_double(Faraday::SoapCall) }
        let(:expected_xml) { requestor.__send__(:request_xml) }
        let(:expected_url) { extract_url_from(requestor.__send__(:wsdl_location)) }

        it "invokes the fadaday soap_call" do
          expect(soap_call).to receive(:call).with(expected_xml).once
          requestor.call
        end
      end
    end
  end
end
