require "rails_helper"
DummyPropertiesStruct = Struct.new(:sheet_id, :grid_properties)
DummyGridPropertiesStruct = Struct.new(:row_count, :column_count)

RSpec.describe DigestExporter do
  # Unable to get VCR to properly record interactions with Google Sheets, so here just testing the
  # expected methods are called

  describe ".call" do
    let(:service_creds) { instance_double Google::Auth::ServiceAccountCredentials, fetch_access_token!: {} }
    let(:sheet_service) { instance_double Google::Apis::SheetsV4::SheetsService }
    let(:spreadsheet) { instance_double Google::Apis::SheetsV4::Spreadsheet }
    let(:worksheet) { instance_double Google::Apis::SheetsV4::Spreadsheet }
    let(:sheet_id) { "123456789" }
    let(:properties) { DummyPropertiesStruct.new(sheet_id, DummyGridPropertiesStruct.new(10, 10)) }
    let(:fixed_time) { Time.zone.now }

    before do
      allow(worksheet).to receive(:properties).and_return(properties)
      allow(properties.grid_properties).to receive(:row_count).and_return(10, 10, 1, 10)
      allow(properties.grid_properties).to receive(:column_count).and_return(10, 10, 1, 10)
      create_list(:application_digest, 4)
    end

    it "loads all the digest records" do
      travel_to fixed_time do
        expect(Google::Auth::ServiceAccountCredentials).to receive(:make_creds).and_return(service_creds)
        expect(service_creds).to receive(:fetch_access_token!).once
        expect(Google::Apis::SheetsV4::SheetsService).to receive(:new).and_return(sheet_service)
        expect(sheet_service).to receive(:authorization=).once
        expect(sheet_service).to receive(:get_spreadsheet).and_return(spreadsheet).twice
        expect(spreadsheet).to receive(:sheets).and_return([worksheet]).twice
        expect(sheet_service).to receive(:batch_update_spreadsheet).twice
        expect(sheet_service).to receive(:update_spreadsheet_value).once

        described_class.call
      end
    end

    context "when saving records silently fails" do
      before { allow(properties.grid_properties).to receive(:row_count).and_return(10) }

      it "calls raises an error and calls AlertManager" do
        travel_to fixed_time do
          expect(Google::Auth::ServiceAccountCredentials).to receive(:make_creds).and_return(service_creds)
          expect(service_creds).to receive(:fetch_access_token!).once
          expect(Google::Apis::SheetsV4::SheetsService).to receive(:new).and_return(sheet_service)
          expect(sheet_service).to receive(:authorization=).once
          expect(sheet_service).to receive(:get_spreadsheet).and_return(spreadsheet).twice
          expect(spreadsheet).to receive(:sheets).and_return([worksheet]).twice
          expect(sheet_service).to receive(:batch_update_spreadsheet).twice

          expect { described_class.call }.to raise_error(DigestExporter::SpreadsheetError, "Spreadsheet not cleared")
        end
      end
    end
  end
end
