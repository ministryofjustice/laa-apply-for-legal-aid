require "rails_helper"

module CFE
  RSpec.describe StoreCompareResult do
    subject(:call_submit_data) { described_class.call(data_submitted) }

    let(:service_creds) { instance_double(Google::Auth::ServiceAccountCredentials, fetch_access_token!: {}) }
    let(:sheet_service) { instance_double(Google::Apis::SheetsV4::SheetsService) }
    let(:spreadsheet) { instance_spy(Google::Apis::SheetsV4::Spreadsheet) }
    let(:data_submitted) { ["Fake", "data", true] }
    let(:append_value_response) { instance_double(Google::Apis::SheetsV4::AppendValuesResponse) }
    let(:update_value_response) { instance_double(Google::Apis::SheetsV4::UpdateValuesResponse) }
    let(:output_response) { "Sheet1!A2:A3" }

    before do
      allow(sheet_service).to receive(:append_spreadsheet_value).and_return(append_value_response)
      allow(append_value_response).to receive(:updates).and_return(update_value_response)
      allow(update_value_response).to receive(:updated_range).and_return(output_response)
    end

    it "submits data to the spreadsheet" do
      expect(Google::Auth::ServiceAccountCredentials).to receive(:make_creds).and_return(service_creds).once
      expect(service_creds).to receive(:fetch_access_token!).once
      expect(Google::Apis::SheetsV4::SheetsService).to receive(:new).and_return(sheet_service).once
      expect(sheet_service).to receive(:authorization=).once
      expect(sheet_service).to receive(:get_spreadsheet).and_return(spreadsheet).once
      expect(sheet_service).to receive(:append_spreadsheet_value).once

      call_submit_data
    end
  end
end
