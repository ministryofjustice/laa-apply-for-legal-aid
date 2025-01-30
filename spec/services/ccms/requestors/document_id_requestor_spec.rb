require "rails_helper"

module CCMS
  module Requestors
    RSpec.describe DocumentIdRequestor, :ccms do
      let(:expected_xml) { ccms_data_from_file "document_id_request.xml" }
      let(:expected_tx_id) { "20190101121530000000" }
      let(:case_ccms_reference) { "1234567890" }
      let(:requestor) { described_class.new(case_ccms_reference, "my_login", type) }
      let(:type) { nil }

      before { DocumentCategoryPopulator.call }

      describe "XML request" do
        context "when sent an uncatergorised document" do
          let(:type) { nil }

          it_behaves_like "a Document Upload Request XML generator" do
            let(:matching) do
              [
                "<casebio:DocumentType>ADMIN1</casebio:DocumentType>",
                "<casebio:Channel>E</casebio:Channel>",
              ]
            end
          end
        end

        context "when the attachment is a means report" do
          let(:type) { "means_report" }

          it_behaves_like "a Document Upload Request XML generator" do
            let(:matching) do
              [
                "<casebio:DocumentType>REPORT</casebio:DocumentType>",
                "<casebio:Text>Means Report</casebio:Text>",
                "<casebio:Channel>E</casebio:Channel>",
              ]
            end
          end
        end

        context "when the attachment is a bank_transaction_report" do
          let(:type) { "bank_transaction_report" }

          it_behaves_like "a Document Upload Request XML generator" do
            let(:matching) do
              [
                "<casebio:DocumentType>BSTMT</casebio:DocumentType>",
                "<casebio:Text>Open Banking Report</casebio:Text>",
                "<casebio:Channel>E</casebio:Channel>",
              ]
            end
          end
        end

        context "when the attachment is a bank_statement_evidence_pdf" do
          let(:type) { "bank_statement_evidence_pdf" }

          it_behaves_like "a Document Upload Request XML generator" do
            let(:matching) do
              [
                "<casebio:DocumentType>BSTMT</casebio:DocumentType>",
                "<casebio:Text>Client Statement</casebio:Text>",
                "<casebio:Channel>E</casebio:Channel>",
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
                "<casebio:Text>Gateway Evidence</casebio:Text>",
                "<casebio:Channel>E</casebio:Channel>",
              ]
            end
          end
        end

        context "when sent a client employment evidence document" do
          let(:type) { "client_employment_evidence_pdf" }

          it_behaves_like "a Document Upload Request XML generator" do
            let(:matching) do
              [
                "<casebio:DocumentType>PAYSLIP</casebio:DocumentType>",
                "<casebio:Text>Client Employment</casebio:Text>",
                "<casebio:Channel>E</casebio:Channel>",
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
                "<casebio:Text>Court Order or Application</casebio:Text>",
                "<casebio:Channel>E</casebio:Channel>",
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
                "<casebio:Text>Passporting Evidence</casebio:Text>",
                "<casebio:Channel>E</casebio:Channel>",
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
                "<casebio:Channel>E</casebio:Channel>",
              ]
            end
          end
        end
      end

      context "when sent a local authority assessment document" do
        let(:type) { "local_authority_assessment_pdf" }

        it_behaves_like "a Document Upload Request XML generator" do
          let(:matching) do
            [
              "<casebio:DocumentType>EX_RPT</casebio:DocumentType>",
              "<casebio:Text>Local Authority Assessment</casebio:Text>",
              "<casebio:Channel>E</casebio:Channel>",
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
              "<casebio:Text>Grounds of Appeal</casebio:Text>",
              "<casebio:Channel>E</casebio:Channel>",
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
              "<casebio:Text>Counsel's opinion</casebio:Text>",
              "<casebio:Channel>E</casebio:Channel>",
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
              "<casebio:Text>Judgement</casebio:Text>",
              "<casebio:Channel>E</casebio:Channel>",
            ]
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
