require "rails_helper"

module CCMS
  module Requestors
    RSpec.describe DocumentIdRequestor, :ccms do
      let(:expected_xml) { ccms_data_from_file "document_id_request.xml" }
      let(:expected_tx_id) { "20190101121530000000" }
      let(:case_ccms_reference) { "1234567890" }
      let(:requestor) { described_class.new(case_ccms_reference, "my_login", type) }
      let(:type) { "means_report" }

      before { DocumentCategoryPopulator.call }

      describe "XML request" do
        context "when the attachment is a means report" do
          let(:type) { "means_report" }

          include_context "with ccms soa configuration"

          it "generates the expected XML" do
            allow(requestor).to receive(:transaction_request_id).and_return(expected_tx_id)
            expect(requestor.formatted_xml).to be_soap_envelope_with(
              command: "casebim:DocumentUploadRQ",
              transaction_id: expected_tx_id,
              matching: %w[
                <casebio:DocumentType>REPORT</casebio:DocumentType>
                <casebio:Channel>E</casebio:Channel>
              ],
            )
          end
        end

        context "when the attachment is a bank_transaction_report" do
          let(:type) { "bank_transaction_report" }

          include_context "with ccms soa configuration"

          it "generates the expected XML" do
            allow(requestor).to receive(:transaction_request_id).and_return(expected_tx_id)
            expect(requestor.formatted_xml).to be_soap_envelope_with(
              command: "casebim:DocumentUploadRQ",
              transaction_id: expected_tx_id,
              matching: %w[
                <casebio:DocumentType>BSTMT</casebio:DocumentType>
                <casebio:Channel>E</casebio:Channel>
              ],
            )
          end
        end

        context "when the attachment is a bank_statement_evidence_pdf" do
          let(:type) { "bank_statement_evidence_pdf" }

          include_context "with ccms soa configuration"

          it "generates the expected XML" do
            allow(requestor).to receive(:transaction_request_id).and_return(expected_tx_id)
            expect(requestor.formatted_xml).to be_soap_envelope_with(
              command: "casebim:DocumentUploadRQ",
              transaction_id: expected_tx_id,
              matching: %w[
                <casebio:DocumentType>BSTMT</casebio:DocumentType>
                <casebio:Channel>E</casebio:Channel>
              ],
            )
          end
        end

        context "when sent a gateway evidence document" do
          let(:type) { "gateway_evidence_pdf" }

          include_context "with ccms soa configuration"

          it "generates the expected XML" do
            allow(requestor).to receive(:transaction_request_id).and_return(expected_tx_id)
            expect(requestor.formatted_xml).to be_soap_envelope_with(
              command: "casebim:DocumentUploadRQ",
              transaction_id: expected_tx_id,
              matching: %w[
                <casebio:DocumentType>EX_RPT</casebio:DocumentType>
                <casebio:Channel>E</casebio:Channel>
              ],
            )
          end
        end

        context "when sent a client employment evidence document" do
          let(:type) { "client_employment_evidence_pdf" }

          include_context "with ccms soa configuration"

          it "generates the expected XML" do
            allow(requestor).to receive(:transaction_request_id).and_return(expected_tx_id)
            expect(requestor.formatted_xml).to be_soap_envelope_with(
              command: "casebim:DocumentUploadRQ",
              transaction_id: expected_tx_id,
              matching: %w[
                <casebio:DocumentType>PAYSLIP</casebio:DocumentType>
                <casebio:Channel>E</casebio:Channel>
              ],
            )
          end
        end

        context "when sent a court_application_or_order_pdf document" do
          let(:type) { "court_application_or_order_pdf" }

          include_context "with ccms soa configuration"

          it "generates the expected XML" do
            allow(requestor).to receive(:transaction_request_id).and_return(expected_tx_id)
            expect(requestor.formatted_xml).to be_soap_envelope_with(
              command: "casebim:DocumentUploadRQ",
              transaction_id: expected_tx_id,
              matching: %w[
                <casebio:DocumentType>COURT_ORD</casebio:DocumentType>
                <casebio:Channel>E</casebio:Channel>
              ],
            )
          end
        end

        context "when sent a benefit_evidence_pdf document" do
          let(:type) { "benefit_evidence_pdf" }

          include_context "with ccms soa configuration"

          it "generates the expected XML" do
            allow(requestor).to receive(:transaction_request_id).and_return(expected_tx_id)
            expect(requestor.formatted_xml).to be_soap_envelope_with(
              command: "casebim:DocumentUploadRQ",
              transaction_id: expected_tx_id,
              matching: %w[
                <casebio:DocumentType>BEN_LTR</casebio:DocumentType>
                <casebio:Channel>E</casebio:Channel>
              ],
            )
          end
        end

        context "when sent a legacy document" do
          let(:type) { "employment_evidence_pdf" }

          include_context "with ccms soa configuration"

          it "generates the expected XML" do
            allow(requestor).to receive(:transaction_request_id).and_return(expected_tx_id)
            expect(requestor.formatted_xml).to be_soap_envelope_with(
              command: "casebim:DocumentUploadRQ",
              transaction_id: expected_tx_id,
              matching: %w[
                <casebio:DocumentType>ADMIN1</casebio:DocumentType>
                <casebio:Channel>E</casebio:Channel>
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
