require "rails_helper"

module CCMS
  module Parsers
    RSpec.describe ReferenceDataResponseParser, :ccms do
      let(:expected_tx_id) { "20190301030405123456" }
      let(:expected_reference_number) { "300000135140" }

      context "when the response is successful" do
        let(:response_xml) { ccms_data_from_file "reference_data_response.xml" }

        describe "#reference_id" do
          it "extracts the reference data" do
            parser = described_class.new(expected_tx_id, response_xml)
            expect(parser.reference_id).to eq expected_reference_number
          end

          it "raises if the transaction_request_ids dont match" do
            expect {
              parser = described_class.new(Faker::Number.number(digits: 20), response_xml)
              parser.reference_id
            }.to raise_error CCMS::CCMSError, "Invalid transaction request id #{expected_tx_id}"
          end
        end

        describe "#success" do
          it "returns true" do
            parser = described_class.new(expected_tx_id, response_xml)
            parser.reference_id
            expect(parser.success).to be true
          end
        end

        describe "#message" do
          it "returns status concatenated with status free text" do
            parser = described_class.new(expected_tx_id, response_xml)
            parser.reference_id
            expect(parser.message).to eq "Success: GetReferenceData Successfully Completed."
          end
        end
      end

      context "when the response fails with message" do
        let(:response_xml) { ccms_data_from_file "reference_data_response_failure.xml" }

        describe "#success" do
          it "returns false" do
            parser = described_class.new(expected_tx_id, response_xml)
            parser.reference_id
            expect(parser.success).to be false
          end
        end

        describe "#message" do
          it "returns status concatenated with status free text" do
            parser = described_class.new(expected_tx_id, response_xml)
            parser.reference_id
            expect(parser.message).to eq "Failed: Failed to retrieve reference id."
          end
        end
      end

      context "when the response fails without message" do
        let(:response_xml) { ccms_data_from_file "reference_data_response_without_status_free_text.xml" }

        describe "#success" do
          it "returns false" do
            parser = described_class.new(expected_tx_id, response_xml)
            parser.reference_id
            expect(parser.success).to be false
          end
        end

        describe "#message" do
          it "returns status concatenated with status free text" do
            parser = described_class.new(expected_tx_id, response_xml)
            parser.reference_id
            expect(parser.message).to eq "Failed: "
          end
        end
      end

      context "when the response fails with a server side exception" do
        let(:response_xml) { ccms_data_from_file "reference_data_response_exception.xml" }

        describe "#success" do
          it "returns false" do
            parser = described_class.new(expected_tx_id, response_xml)
            parser.reference_id
            expect(parser.success).to be false
          end
        end

        describe "#message" do
          it "returns exception message concatenated with status and status free text" do
            parser = described_class.new(expected_tx_id, response_xml)
            parser.reference_id
            expect(parser.message).to eq "Server side exception: Error: User does not have valid responsibility associated."
          end
        end
      end

      context "when the response fails and the case_ccms_reference is ERROR" do
        let(:response_xml) { ccms_data_from_file "reference_data_response_error.xml" }

        it "returns false" do
          expect {
            parser = described_class.new(expected_tx_id, response_xml)
            parser.reference_id
          }.to raise_error CCMS::CCMSError, "case_ccms_reference returned as ERROR"
        end
      end
    end
  end
end
