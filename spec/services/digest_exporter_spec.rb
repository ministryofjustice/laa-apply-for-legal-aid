require "rails_helper"

RSpec.describe DigestExporter do
  # Unable to get VCR to properly record interactions with Google Sheets, so here just testing the
  # expected methods are called
  describe ".call" do
    let(:google_session) { double GoogleDrive::Session }
    let(:spreadsheet) { double "Spreadsheet", worksheets: {} }
    # let(:archive) { double "Worksheet", rows: {} }
    let(:worksheet) { double "Worksheet", rows: {}, delete: true }
    let(:column_headings) { [ApplicationDigest.column_headers + [extracted_at]].flatten }
    let(:fixed_time) { Time.zone.now }
    let(:extracted_at) { "Extracted at: #{fixed_time.strftime('%Y-%m-%d %H:%M:%S %z')}" }
    let(:rows) { ApplicationDigest.order(:created_at).map(&:to_google_sheet_row) }
    let(:expected_rows) { [column_headings] + rows }

    before do
      allow(spreadsheet).to receive(:add_worksheet).and_return(worksheet)
      allow(worksheet.rows).to receive(:count).and_return(10)
      allow(worksheet).to receive(:num_cols).and_return(2)
      allow(worksheet).to receive(:[]).with(1, 2).and_return("Fake extraction date")
      allow(worksheet).to receive(:title=).with("Archive fake extraction date").and_return("Archive fake extraction date")
      create_list(:application_digest, 4)
    end

    it "loads all the digest records" do
      travel_to fixed_time do
        expect(GoogleDrive::Session).to receive(:from_service_account_key).and_return(google_session)
        expect(google_session).to receive(:spreadsheet_by_key).and_return(spreadsheet).once
        expect(spreadsheet).to receive(:worksheets).and_return([worksheet]).at_least(2)
        expect(worksheet).to receive(:num_cols).and_return(2)
        expect(worksheet).to receive(:save).twice
        expect(worksheet).to receive(:update_cells).once

        described_class.call
      end
    end

    context "when sheets need archiving" do
      it "deletes the third worksheet" do
        travel_to fixed_time do
          expect(GoogleDrive::Session).to receive(:from_service_account_key).and_return(google_session)
          expect(google_session).to receive(:spreadsheet_by_key).and_return(spreadsheet).once
          expect(spreadsheet).to receive(:worksheets).and_return([worksheet, worksheet, worksheet]).at_least(2)
          expect(worksheet).to receive(:num_cols).and_return(2)
          expect(worksheet).to receive(:delete).once
          expect(worksheet).to receive(:save).twice
          expect(worksheet).to receive(:update_cells).once

          described_class.call
        end
      end
    end

    context "when saving records fails" do
      before { allow(worksheet.rows).to receive(:count).and_return(1) }

      it "calls raises an error and calls AlertManager" do
        travel_to fixed_time do
          expect(GoogleDrive::Session).to receive(:from_service_account_key).and_return(google_session)
          expect(google_session).to receive(:spreadsheet_by_key).and_return(spreadsheet).once
          expect(spreadsheet).to receive(:worksheets).and_return([worksheet]).once
          expect(worksheet).to receive(:save).twice
          expect(worksheet).to receive(:update_cells).once
          expect(AlertManager).to receive(:capture_exception).with(message_contains("Spreadsheet unexpectedly empty"))
          expect { described_class.call }.to raise_error(DigestExporter::SpreadsheetEmpty)
        end
      end
    end
  end
end
