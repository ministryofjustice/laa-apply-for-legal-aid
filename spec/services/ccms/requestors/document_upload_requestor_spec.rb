require "rails_helper"
module CCMS
  module Requestors
    RSpec.describe DocumentUploadRequestor, :ccms do
      let(:expected_xml) { ccms_data_from_file "document_upload_request.xml" }
      let(:expected_tx_id) { "20190101121530000000" }
      let(:case_ccms_reference) { "1234567890" }
      let(:document_id) { "4420073" }
      let(:document_encoded_base64) { "JVBERi0xLjUNCiW1tbW1DQoxIDAgb2JqDQo8PC9UeXBlL0NhdGFsb2cvUGFnZXMgMiA" }
      let(:requestor) { described_class.new(case_ccms_reference, document_id, document_encoded_base64, "my_login", type) }
      let(:type) { nil }

      before { DocumentCategoryPopulator.call }

      describe "XML request" do
        context "when sent an uncatergorised document" do
          let(:type) { nil }

          it_behaves_like "a Document Upload Request XML generator" do
            let(:matching) do
              [
                "<casebio:DocumentType>ADMIN1</casebio:DocumentType>",
                "<casebio:FileExtension>pdf</casebio:FileExtension>",
              ]
            end
          end
        end

        context "when sent a means report" do
          let(:type) { "means_report" }

          it_behaves_like "a Document Upload Request XML generator" do
            let(:matching) do
              [
                "<casebio:DocumentType>REPORT</casebio:DocumentType>",
                "<casebio:FileExtension>pdf</casebio:FileExtension>",
                "<casebio:Text>Means Report</casebio:Text>",
              ]
            end
          end
        end

        context "when sent a gateway evidence document" do
          let(:type) { "gateway_evidence_pdf" }

          it_behaves_like "a Document Upload Request XML generator" do
            let(:matching) do
              [
                "<casebio:DocumentType>EX_RPT</casebio:DocumentType>",
                "<casebio:FileExtension>pdf</casebio:FileExtension>",
                "<casebio:Text>Gateway Evidence</casebio:Text>",
              ]
            end
          end
        end

        context "when sent a bank_transaction_report" do
          let(:type) { "bank_transaction_report" }

          it_behaves_like "a Document Upload Request XML generator" do
            let(:matching) do
              [
                "<casebio:DocumentType>BSTMT</casebio:DocumentType>",
                "<casebio:FileExtension>csv</casebio:FileExtension>",
                "<casebio:Text>Open Banking Report</casebio:Text>",
              ]
            end
          end
        end

        context "when sent a bank_statement_evidence_pdf document" do
          let(:type) { "bank_statement_evidence_pdf" }

          it_behaves_like "a Document Upload Request XML generator" do
            let(:matching) do
              [
                "<casebio:DocumentType>BSTMT</casebio:DocumentType>",
                "<casebio:FileExtension>pdf</casebio:FileExtension>",
                "<casebio:Text>Client Statement</casebio:Text>",
              ]
            end
          end
        end

        context "when sent a part_bank_state_evidence_pdf document" do
          let(:type) { "part_bank_state_evidence_pdf" }

          it_behaves_like "a Document Upload Request XML generator" do
            let(:matching) do
              [
                "<casebio:DocumentType>BSTMT</casebio:DocumentType>",
                "<casebio:FileExtension>pdf</casebio:FileExtension>",
                "<casebio:Text>Partner Statement</casebio:Text>",
              ]
            end
          end
        end

        context "when sent a client_employment_evidence_pdf document" do
          let(:type) { "client_employment_evidence_pdf" }

          it_behaves_like "a Document Upload Request XML generator" do
            let(:matching) do
              [
                "<casebio:DocumentType>PAYSLIP</casebio:DocumentType>",
                "<casebio:FileExtension>pdf</casebio:FileExtension>",
                "<casebio:Text>Client Employment</casebio:Text>",
              ]
            end
          end
        end

        context "when sent a court_application_or_order_pdf document" do
          let(:type) { "court_application_or_order_pdf" }

          it_behaves_like "a Document Upload Request XML generator" do
            let(:matching) do
              [
                "<casebio:DocumentType>COURT_ORD</casebio:DocumentType>",
                "<casebio:FileExtension>pdf</casebio:FileExtension>",
                "<casebio:Text>Court Order or Application</casebio:Text>",
              ]
            end
          end
        end

        context "when sent a benefit_evidence_pdf document" do
          let(:type) { "benefit_evidence_pdf" }

          it_behaves_like "a Document Upload Request XML generator" do
            let(:matching) do
              [
                "<casebio:DocumentType>BEN_LTR</casebio:DocumentType>",
                "<casebio:FileExtension>pdf</casebio:FileExtension>",
                "<casebio:Text>Passporting Evidence</casebio:Text>",
              ]
            end
          end
        end

        context "when sent a statement of case document" do
          let(:type) { "statement_of_case_pdf" }

          it_behaves_like "a Document Upload Request XML generator" do
            let(:matching) do
              [
                "<casebio:DocumentType>STATE</casebio:DocumentType>",
                "<casebio:FileExtension>pdf</casebio:FileExtension>",
                "<casebio:Text>Statement of Case</casebio:Text>",
              ]
            end
          end
        end

        context "when sent a legacy document" do
          let(:type) { "employment_evidence_pdf" }

          it_behaves_like "a Document Upload Request XML generator" do
            let(:matching) do
              [
                "<casebio:DocumentType>ADMIN1</casebio:DocumentType>",
                "<casebio:FileExtension>pdf</casebio:FileExtension>",
              ]
            end
          end
        end

        context "when sent a local authority assessment document" do
          let(:type) { "local_authority_assessment_pdf" }

          it_behaves_like "a Document Upload Request XML generator" do
            let(:matching) do
              [
                "<casebio:DocumentType>EX_RPT</casebio:DocumentType>",
                "<casebio:FileExtension>pdf</casebio:FileExtension>",
                "<casebio:Text>Local Authority Assessment</casebio:Text>",
              ]
            end
          end
        end

        context "when sent a grounds of appeal document" do
          let(:type) { "grounds_of_appeal_pdf" }

          it_behaves_like "a Document Upload Request XML generator" do
            let(:matching) do
              [
                "<casebio:DocumentType>APL_EV</casebio:DocumentType>",
                "<casebio:FileExtension>pdf</casebio:FileExtension>",
                "<casebio:Text>Grounds of Appeal</casebio:Text>",
              ]
            end
          end
        end

        context "when sent a counsel's opinion document" do
          let(:type) { "counsel_opinion_pdf" }

          it_behaves_like "a Document Upload Request XML generator" do
            let(:matching) do
              [
                "<casebio:DocumentType>COUNSEL</casebio:DocumentType>",
                "<casebio:FileExtension>pdf</casebio:FileExtension>",
                "<casebio:Text>Counsel's opinion</casebio:Text>",
              ]
            end
          end
        end

        context "when sent a judgement document" do
          let(:type) { "judgement_pdf" }

          it_behaves_like "a Document Upload Request XML generator" do
            let(:matching) do
              [
                "<casebio:DocumentType>OUT_EV</casebio:DocumentType>",
                "<casebio:FileExtension>pdf</casebio:FileExtension>",
                "<casebio:Text>Judgement</casebio:Text>",
              ]
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

        it "invokes the faraday soap_call" do
          expect(soap_call).to receive(:call).with(expected_xml).once
          requestor.call
        end
      end
    end
  end
end
