require "rails_helper"

module CFE
  RSpec.describe ResetGoogleSheetFilter do
    subject(:call_reset) { described_class.call }

    let(:service_creds) { instance_double(Google::Auth::ServiceAccountCredentials, fetch_access_token!: {}) }
    let(:sheet_service) { instance_double(Google::Apis::SheetsV4::SheetsService) }
    let(:spreadsheet) { instance_spy(Google::Apis::SheetsV4::Spreadsheet) }
    let(:sheet) { instance_spy(Google::Apis::SheetsV4::Spreadsheet) }
    let(:sheet_properties) { instance_spy(Google::Apis::SheetsV4::SheetProperties) }
    let(:sheet_id) { "123456789" }

    before do
      allow(spreadsheet).to receive(:sheets).and_return([sheet])
      allow(sheet).to receive(:properties).and_return(sheet_properties)
      allow(sheet_properties).to receive(:sheet_id).and_return(sheet_id)
    end

    it "submits data to the spreadsheet" do
      expect(Google::Auth::ServiceAccountCredentials).to receive(:make_creds).and_return(service_creds).once
      expect(service_creds).to receive(:fetch_access_token!).once
      expect(Google::Apis::SheetsV4::SheetsService).to receive(:new).and_return(sheet_service).once
      expect(sheet_service).to receive(:authorization=).once
      expect(sheet_service).to receive(:get_spreadsheet).and_return(spreadsheet).once
      expect(sheet_service).to receive(:batch_update_spreadsheet).once

      call_reset
    end
  end
end
