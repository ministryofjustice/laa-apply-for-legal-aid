require "rails_helper"

module CCMS
  module Requestors
    RSpec.describe ApplicantSearchRequestor, :ccms do
      let(:expected_tx_id) { "20190101121530000000" }
      let(:applicant) do
        create(:applicant,
               first_name: "lenovo",
               last_name: "hurlock",
               date_of_birth: Date.new(1969, 1, 1),
               national_insurance_number: "YS327299B")
      end
      let(:requestor) { described_class.new(applicant, "my_login") }

      describe "XML request" do
        include_context "with ccms soa configuration"

        it "generates the expected XML" do
          allow(requestor).to receive(:transaction_request_id).and_return(expected_tx_id)
          expect(requestor.formatted_xml).to be_soap_envelope_with(
            command: "clientbim:ClientInqRQ",
            transaction_id: expected_tx_id,
            matching: %w[
              <clientbio:Surname>hurlock</clientbio:Surname>
              <clientbio:FirstName>lenovo</clientbio:FirstName>
            ],
          )
        end

        context "when the applicant has a surname_at_birth" do
          let(:applicant) do
            create(:applicant,
                   first_name: "lenovo",
                   last_name: "hurlock",
                   last_name_at_birth: "different",
                   date_of_birth: Date.new(1969, 1, 1),
                   national_insurance_number: "YS327299B")
          end

          it "generates the expected XML" do
            allow(requestor).to receive(:transaction_request_id).and_return(expected_tx_id)
            expect(requestor.formatted_xml).to be_soap_envelope_with(
              command: "clientbim:ClientInqRQ",
              transaction_id: expected_tx_id,
              matching: %w[
                <clientbio:Surname>different</clientbio:Surname>
                <clientbio:FirstName>lenovo</clientbio:FirstName>
              ],
            )
          end
        end

        context "when the applicant has a name containing a special character" do
          let(:applicant) do
            create(:applicant,
                   first_name:,
                   last_name:,
                   date_of_birth: Date.new(1969, 1, 1),
                   national_insurance_number: "YS327299B")
          end

          context "when the last name contains an opening single curly quote" do
            let(:last_name) { "O‘Hare" }
            let(:first_name) { "lenovo" }

            it "generates the expected XML" do
              allow(requestor).to receive(:transaction_request_id).and_return(expected_tx_id)
              expect(requestor.formatted_xml).to be_soap_envelope_with(
                command: "clientbim:ClientInqRQ",
                transaction_id: expected_tx_id,
                matching: %w[
                  <clientbio:Surname>O'Hare</clientbio:Surname>
                  <clientbio:FirstName>lenovo</clientbio:FirstName>
                ],
              )
            end
          end

          context "when the first name contains an closing single curly quote" do
            let(:last_name) { "hurlock" }
            let(:first_name) { "l’novo" }

            it "generates the expected XML" do
              allow(requestor).to receive(:transaction_request_id).and_return(expected_tx_id)
              expect(requestor.formatted_xml).to be_soap_envelope_with(
                command: "clientbim:ClientInqRQ",
                transaction_id: expected_tx_id,
                matching: %w[
                  <clientbio:Surname>hurlock</clientbio:Surname>
                  <clientbio:FirstName>l'novo</clientbio:FirstName>
                ],
              )
            end
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
