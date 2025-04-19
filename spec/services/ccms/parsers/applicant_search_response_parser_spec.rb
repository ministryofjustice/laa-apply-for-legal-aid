require "rails_helper"

module CCMS
  module Parsers
    RSpec.describe ApplicantSearchResponseParser, :ccms do
      describe "parsing applicant search responses" do
        let(:no_results_response_xml) { ccms_data_from_file "applicant_search_response_no_results.xml" }
        let(:parser) { described_class.new(Faker::Number.number(digits: 20), no_results_response_xml, applicant) }
        let(:applicant) { create(:applicant) }
        let(:expected_tx_id) { "20190301030405123456" }

        it "raises if the transaction_request_ids dont match" do
          expect {
            parser.record_count
          }.to raise_error CCMS::CCMSError, "Invalid transaction request id #{expected_tx_id}"
        end

        context "when there are no applicants returned" do
          let(:parser) { described_class.new(expected_tx_id, no_results_response_xml, applicant) }

          it "extracts the number of records fetched" do
            expect(parser.record_count).to eq "0"
          end

          it "does not return an applicant_ccms_reference" do
            expect(parser.applicant_ccms_reference).to be_nil
          end

          it "expects logger to receive" do
            expect(Rails.logger).to receive(:info).with("CCMS::Parsers::ApplicantSearchResponseParser:: CCMS records returned: 0, Full matches: 0, ChosenMatch: ")
            parser.applicant_ccms_reference
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

        context "when one search result is returned" do
          let(:expected_tx_id) { "202210201539485477193605161" }
          let(:parser) { described_class.new(expected_tx_id, ccms_data_from_file("applicant_search_responses/one_result_match.xml"), applicant) }

          context "and the civil apply applicant data exactly matches" do
            let(:applicant) { create(:applicant, first_name: "Amy", last_name: "Williams", date_of_birth: Date.new(1972, 1, 1), national_insurance_number: "QQ123456A") }

            it "extracts the number of records fetched" do
              expect(parser.record_count).to eq "1"
            end

            it "returns the applicant_ccms_reference" do
              expect(parser.applicant_ccms_reference).to eq "4390016"
            end

            it "expects logger to receive" do
              expect(Rails.logger).to receive(:info).with("CCMS::Parsers::ApplicantSearchResponseParser:: CCMS records returned: 1, Full matches: 1, ChosenMatch: 4390016")
              parser.applicant_ccms_reference
            end
          end

          context "and the civil apply applicant data exactly matches the first initial" do
            let(:applicant) { create(:applicant, first_name: "Amelia", last_name: "Williams", date_of_birth: Date.new(1972, 1, 1), national_insurance_number: "QQ123456A") }

            it "extracts the number of records fetched" do
              expect(parser.record_count).to eq "1"
            end

            it "returns the applicant_ccms_reference" do
              expect(parser.applicant_ccms_reference).to eq "4390016"
            end

            it "expects logger to receive" do
              expect(Rails.logger).to receive(:info).with("CCMS::Parsers::ApplicantSearchResponseParser:: CCMS records returned: 1, Full matches: 1, ChosenMatch: 4390016")
              parser.applicant_ccms_reference
            end
          end

          context "and the civil apply applicant name data does not match but Number Matched is true" do
            let(:applicant) { create(:applicant, first_name: "Amy", last_name: "Pond", date_of_birth: Date.new(1972, 1, 1), national_insurance_number: "QQ123456A") }

            it "returns nil" do
              expect(parser.applicant_ccms_reference).to be_nil
            end

            it "expects logger to receive" do
              expect(Rails.logger).to receive(:info).with("CCMS::Parsers::ApplicantSearchResponseParser:: CCMS records returned: 1, Full matches: 0, ChosenMatch: ")
              parser.applicant_ccms_reference
            end
          end

          context "and the applicant's name contains a special character" do
            context "and the applicant's last name contains an opening curly quote" do
              let(:parser) { described_class.new(expected_tx_id, ccms_data_from_file("applicant_search_responses/special_characters_match.xml"), applicant) }
              let(:applicant) { create(:applicant, first_name: "lenovo", last_name: "O‘Hare", date_of_birth: Date.new(1972, 1, 1), national_insurance_number: "QQ123456A") }

              it "extracts the number of records fetched" do
                expect(parser.record_count).to eq "1"
              end

              it "returns the applicant_ccms_reference" do
                expect(parser.applicant_ccms_reference).to eq "4390016"
              end

              it "expects logger to receive" do
                expect(Rails.logger).to receive(:info).with("CCMS::Parsers::ApplicantSearchResponseParser:: CCMS records returned: 1, Full matches: 1, ChosenMatch: 4390016")
                parser.applicant_ccms_reference
              end
            end

            context "and the applicant's last name contains an closing curly quote" do
              let(:parser) { described_class.new(expected_tx_id, ccms_data_from_file("applicant_search_responses/special_characters_match.xml"), applicant) }
              let(:applicant) { create(:applicant, first_name: "lenovo", last_name: "O’Hare", date_of_birth: Date.new(1972, 1, 1), national_insurance_number: "QQ123456A") }

              it "extracts the number of records fetched" do
                expect(parser.record_count).to eq "1"
              end

              it "returns the applicant_ccms_reference" do
                expect(parser.applicant_ccms_reference).to eq "4390016"
              end

              it "expects logger to receive" do
                expect(Rails.logger).to receive(:info).with("CCMS::Parsers::ApplicantSearchResponseParser:: CCMS records returned: 1, Full matches: 1, ChosenMatch: 4390016")
                parser.applicant_ccms_reference
              end
            end
          end
        end

        context "when the result has a single record with Number Not Held" do
          let(:expected_tx_id) { "202210201539485477193605161" }
          let(:parser) { described_class.new(expected_tx_id, ccms_data_from_file("applicant_search_responses/one_result_number_not_held.xml"), applicant) }
          let(:applicant) { create(:applicant, first_name: "Amy", last_name: "Williams", date_of_birth: Date.new(1972, 1, 1), national_insurance_number:) }

          context "when civil apply has a National Insurance NUmber" do
            let(:national_insurance_number) { "QQ123456A" }

            it "returns nil" do
              expect(parser.applicant_ccms_reference).to be_nil
            end

            it "expects logger to receive" do
              expect(Rails.logger).to receive(:info).with("CCMS::Parsers::ApplicantSearchResponseParser:: CCMS records returned: 1, Full matches: 0, ChosenMatch: ")
              parser.applicant_ccms_reference
            end
          end

          context "when Civil Apply also does not have a National Insurance Number" do
            let(:national_insurance_number) { nil }

            it "returns nil" do
              expect(parser.applicant_ccms_reference).to be_nil
            end

            it "expects logger to receive" do
              expect(Rails.logger).to receive(:info).with("CCMS::Parsers::ApplicantSearchResponseParser:: CCMS records returned: 1, Full matches: 0, ChosenMatch: ")
              parser.applicant_ccms_reference
            end
          end
        end

        context "when more than one search result is returned" do
          let(:expected_tx_id) { "202210201539485477193605161" }
          let(:parser) { described_class.new(expected_tx_id, data_file, applicant) }
          let(:data_file) { ccms_data_from_file("applicant_search_responses/multi_match_name_change.xml") }

          context "and the civil apply applicant data exactly matches the recent record" do
            # simulates an applicant that has applied twice before and is still using the most recent data
            let(:applicant) { create(:applicant, first_name: "Amy", last_name: "Williams", last_name_at_birth: "Pond", date_of_birth: Date.new(1972, 1, 1), national_insurance_number: "QQ123456A") }

            it "extracts the number of records fetched" do
              expect(parser.record_count).to eq "2"
            end

            it "returns the applicant_ccms_reference" do
              expect(parser.applicant_ccms_reference).to eq "61417612"
            end

            it "expects logger to receive" do
              expect(Rails.logger).to receive(:info).with("CCMS::Parsers::ApplicantSearchResponseParser:: CCMS records returned: 2, Full matches: 1, ChosenMatch: 61417612")
              parser.applicant_ccms_reference
            end
          end

          context "and the civil apply applicant data exactly matches the first initial and all other data" do
            let(:applicant) { create(:applicant, first_name: "Amelia", last_name: "Williams", last_name_at_birth: "Pond", date_of_birth: Date.new(1972, 1, 1), national_insurance_number: "QQ123456A") }

            it "extracts the number of records fetched" do
              expect(parser.record_count).to eq "2"
            end

            it "returns the applicant_ccms_reference" do
              expect(parser.applicant_ccms_reference).to eq "61417612"
            end

            it "expects logger to receive" do
              expect(Rails.logger).to receive(:info).with("CCMS::Parsers::ApplicantSearchResponseParser:: CCMS records returned: 2, Full matches: 1, ChosenMatch: 61417612")
              parser.applicant_ccms_reference
            end
          end

          context "and the civil apply applicant data exactly matches an earlier record" do
            # simulates an applicant that has applied multiple times and reverted to their surname at birth since previous application
            let(:applicant) { create(:applicant, first_name: "Amy", last_name: "Pond", last_name_at_birth: "Pond", date_of_birth: Date.new(1972, 1, 1), national_insurance_number: "QQ123456A") }

            it "extracts the number of records fetched" do
              expect(parser.record_count).to eq "2"
            end

            it "returns the applicant_ccms_reference" do
              expect(parser.applicant_ccms_reference).to eq "6433884"
            end

            it "expects logger to receive" do
              expect(Rails.logger).to receive(:info).with("CCMS::Parsers::ApplicantSearchResponseParser:: CCMS records returned: 2, Full matches: 1, ChosenMatch: 6433884")
              parser.applicant_ccms_reference
            end
          end

          context "and the civil apply applicant last_name data does not match but NI Number is matched is true" do
            # simulates an applicant being created twice in CCMS and the duplicate client job has not yet been resolved by a caseworker
            let(:data_file) { ccms_data_from_file("applicant_search_responses/multi_match_duplicate_records.xml") }
            let(:applicant) { create(:applicant, first_name: "Amy", last_name: "Pond", last_name_at_birth: "Pond", date_of_birth: Date.new(1972, 1, 1), national_insurance_number: "QQ123456A") }

            it "returns nil" do
              expect(parser.applicant_ccms_reference).to be_nil
            end

            it "expects logger to receive" do
              expect(Rails.logger).to receive(:info).with("CCMS::Parsers::ApplicantSearchResponseParser:: CCMS records returned: 2, Full matches: 2, ChosenMatch: ")
              parser.applicant_ccms_reference
            end
          end

          context "and the civil apply applicant first name data does not match but NI Number is matched is true" do
            # simulates an applicant that has changed their first name since previous application
            let(:applicant) { create(:applicant, first_name: "Melody", last_name: "Pond", last_name_at_birth: "Pond", date_of_birth: Date.new(1972, 1, 1), national_insurance_number: "QQ123456A") }

            it "returns nil" do
              expect(parser.applicant_ccms_reference).to be_nil
            end

            it "expects logger to receive" do
              expect(Rails.logger).to receive(:info).with("CCMS::Parsers::ApplicantSearchResponseParser:: CCMS records returned: 2, Full matches: 0, ChosenMatch: ")
              parser.applicant_ccms_reference
            end
          end
        end
      end
    end
  end
end
