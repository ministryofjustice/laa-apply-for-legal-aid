require "rails_helper"

module CCMS
  module Parsers
    RSpec.describe ApplicantSearchResponseParser, :ccms do
      describe "parsing applicant search responses" do
        let(:no_results_response_xml) { ccms_data_from_file "applicant_search_response_no_results.xml" }
        let(:one_result_response_xml) { ccms_data_from_file "applicant_search_response_one_result.xml" }
        let(:number_not_matched_response_xml) { ccms_data_from_file "applicant_search_response_number_not_matched.xml" }
        let(:multiple_results_response_xml) { ccms_data_from_file "applicant_search_response_multiple_results.xml" }
        let(:parser) { described_class.new(Faker::Number.number(digits: 20), no_results_response_xml) }
        let(:expected_tx_id) { "20190301030405123456" }

        it "raises if the transaction_request_ids dont match" do
          expect {
            parser.record_count
          }.to raise_error CCMS::CCMSError, "Invalid transaction request id #{expected_tx_id}"
        end

        context "when there are no applicants returned" do
          let(:parser) { described_class.new(expected_tx_id, no_results_response_xml) }

          it "extracts the number of records fetched" do
            expect(parser.record_count).to eq "0"
          end

          it "does not return an applicant_ccms_reference" do
            expect(parser.applicant_ccms_reference).to be_nil
          end

          describe "#success" do
            it "returns true" do
              parser.record_count
              expect(parser.success).to be true
            end
          end

          describe "#message" do
            it "returns status and message" do
              parser.record_count
              expect(parser.message).to eq "Success: End of Get Party details process."
            end
          end
        end

        context "when there is one applicant returned" do
          let(:parser) { described_class.new(expected_tx_id, one_result_response_xml) }

          it "extracts the number of records fetched" do
            expect(parser.record_count).to eq "1"
          end

          it "returns the applicant_ccms_reference" do
            expect(parser.applicant_ccms_reference).to eq "4390016"
          end

          describe "#success" do
            it "returns true" do
              parser.record_count
              expect(parser.success).to be true
            end
          end

          describe "#message" do
            it "returns status and message" do
              parser.record_count
              expect(parser.message).to eq "Success: End of Get Party details process."
            end
          end
        end

        context "when there are multiple applicants returned" do
          let(:parser) { described_class.new(expected_tx_id, multiple_results_response_xml) }

          it "extracts the number of records fetched" do
            expect(parser.record_count).to eq "2"
          end

          it "returns the first applicant_ccms_reference" do
            expect(parser.applicant_ccms_reference).to eq "4390017"
          end

          describe "#success" do
            it "returns true" do
              parser.record_count
              expect(parser.success).to be true
            end
          end

          describe "#message" do
            it "returns status and message" do
              parser.record_count
              expect(parser.message).to eq "Success: End of Get Party details process."
            end
          end
        end

        context "when the Client NI number is returned as Number Not Matched" do
          let(:expected_tx_id) { "202206241623547511370989944" }
          let(:parser) { described_class.new(expected_tx_id, number_not_matched_response_xml) }

          describe "#applicant_ccms_reference" do
            it "returns nil" do
              expect(parser.applicant_ccms_reference).to be_nil
            end
          end
        end

        context "when the Client NI number is returned as Number Not Held" do
          let(:expected_tx_id) { "202206241623547511370989944" }
          let(:parser) { described_class.new(expected_tx_id, ccms_data_from_file("applicant_search_response_number_not_held.xml")) }

          describe "#applicant_ccms_reference" do
            it "returns nil" do
              expect(parser.applicant_ccms_reference).to be_nil
            end
          end
        end

        context "when there are multiple Client NI numbers returned as Number Not Matched" do
          let(:expected_tx_id) { "202209261614043422799016219" }
          let(:parser) { described_class.new(expected_tx_id, ccms_data_from_file("applicant_search_response_multiple_number_not_matched.xml")) }

          describe "#applicant_ccms_reference" do
            it "returns nil" do
              expect(parser.applicant_ccms_reference).to be_nil
            end
          end
        end
      end
    end
  end
end
