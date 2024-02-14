require "rails_helper"

module CCMS
  module Requestors
    RSpec.describe ReferenceDataRequestor, :ccms do
      let(:expected_xml) { ccms_data_from_file "reference_data_request.xml" }
      let(:expected_tx_id) { "20190101121530000000" }
      let(:requestor) { described_class.new("my_login") }

      describe "XML request" do
        include_context "with ccms soa configuration"

        it "generates the expected XML" do
          allow(requestor).to receive(:transaction_request_id).and_return(expected_tx_id)
          expect(requestor.formatted_xml).to be_soap_envelope_with(
            command: "refdatabim:ReferenceDataInqRQ",
            transaction_id: expected_tx_id,
            matchers: [
              "<hdr:Language>ENG</hdr:Language>",
            ],
          )
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

        it "invokes the faraday soap_call" do
          expect(soap_call).to receive(:call).with(expected_xml).once
          requestor.call
        end
      end
    end
  end
end
