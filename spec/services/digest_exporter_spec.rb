require "rails_helper"

RSpec.describe DigestExporter do
  # Unable to get VCR to properly record interactions with Google Sheets, so here just testing the
  # expected methods are called
  describe ".call" do
    let(:google_session) { double GoogleDrive::Session }
    let(:spreadsheet) { double "Spreadsheet" }
    let(:worksheet) { double "Worksheet", rows: {} }
    let(:column_headings) { ApplicationDigest.column_headers + [extracted_at] }
    let(:fixed_time) { Time.zone.now }
    let(:extracted_at) { "Extracted at: #{fixed_time.strftime('%Y-%m-%d %H:%M:%S %z')}" }
    let(:rows) { ApplicationDigest.order(:created_at).map(&:to_google_sheet_row) }

    before do
      allow(worksheet.rows).to receive(:count).and_return(10)
      create_list(:application_digest, 4)
    end

    it "loads all the digest records" do
      travel_to fixed_time do
        expect(GoogleDrive::Session).to receive(:from_service_account_key).and_return(google_session)
        expect(google_session).to receive(:spreadsheet_by_key).and_return(spreadsheet).once
        expect(spreadsheet).to receive(:worksheets).and_return([worksheet]).once
        expect(spreadsheet).to receive(:batch_update).twice
        expect(worksheet).to receive(:max_rows).at_least(:once).and_return(10, 10, 10, 1, 10)
        expect(worksheet).to receive(:max_cols).at_least(:once).and_return(10, 10, 1)
        expect(worksheet).to receive(:sheet_id).at_least(:once).and_return("123456789")
        expect(worksheet).to receive(:save).once
        expect(worksheet).to receive(:update_cells).once
        expect(worksheet).to receive(:reload).once

        described_class.call
      end
    end

    context "when saving records silently fails" do
      before { allow(worksheet.rows).to receive(:count).and_return(1) }

      it "calls raises an error and calls AlertManager" do
        travel_to fixed_time do
          expect(GoogleDrive::Session).to receive(:from_service_account_key).and_return(google_session)
          expect(google_session).to receive(:spreadsheet_by_key).and_return(spreadsheet).once
          expect(spreadsheet).to receive(:worksheets).and_return([worksheet]).once
          expect(spreadsheet).to receive(:batch_update).twice
          expect(worksheet).to receive(:max_rows).at_least(:once).and_return(10, 10, 10, 1)
          expect(worksheet).to receive(:max_cols).at_least(:once).and_return(10, 10, 1)
          expect(worksheet).to receive(:sheet_id).at_least(:once).and_return("123456789")
          expect(worksheet).to receive(:save).once
          expect(worksheet).to receive(:update_cells).once
          expect(worksheet).to receive(:reload).once
          expect(AlertManager).to receive(:capture_exception).with(message_contains("Spreadsheet unexpectedly empty"))

          expect { described_class.call }.to raise_error(DigestExporter::SpreadsheetError)
        end
      end
    end
  end
end
