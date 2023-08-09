require "rails_helper"

module CCMS
  module Parsers
    RSpec.describe CaseAddResponseParser, :ccms do
      let(:expected_tx_id) { "20190301030405123456" }

      context "when the response is successful" do
        let(:response_xml) { ccms_data_from_file "case_add_response.xml" }

        describe "#success?" do
          it "extracts the status" do
            parser = described_class.new(expected_tx_id, response_xml)
            expect(parser.success?).to be true
          end

          it "raises if the transaction_request_ids dont match" do
            expect {
              parser = described_class.new(Faker::Number.number(digits: 20), response_xml)
              parser.success?
            }.to raise_error CCMS::CCMSError, "Invalid transaction request id #{expected_tx_id}"
          end
        end

        describe "#success" do
          it "returns true" do
            parser = described_class.new(expected_tx_id, response_xml)
            parser.success?
            expect(parser.success).to be true
          end
        end

        describe "#message" do
          it "returns status concatenated with status free text" do
            parser = described_class.new(expected_tx_id, response_xml)
            parser.success?
            expect(parser.message).to eq "Success: "
          end
        end
      end

      context "when the response is unsuccessful" do
        let(:response_xml) { ccms_data_from_file "case_add_response_failure.xml" }

        describe "#success?" do
          it "extracts the status" do
            parser = described_class.new(expected_tx_id, response_xml)
            expect(parser.success?).to be false
          end
        end

        describe "#message" do
          it "returns status concatenated with status free text" do
            parser = described_class.new(expected_tx_id, response_xml)
            parser.success?
            expect(parser.message).to eq "Fail: "
          end
        end
      end
    end
  end
end
