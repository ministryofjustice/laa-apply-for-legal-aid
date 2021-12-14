require 'rails_helper'

RSpec.describe DigestExporter do
  # Unable to get VCR to properly record interactions with Google Sheets, so here just testing the
  # expected methods are called
  describe '.call' do
    let(:google_session) { double GoogleDrive::Session }
    let(:spreadsheet) { double 'Spreadsheet' }
    let(:worksheet) { double 'Worksheet' }
    let(:column_headings) { ApplicationDigest.column_headers + [extracted_at] }
    let(:fixed_time) { Time.zone.now }
    let(:extracted_at) { "Extracted at: #{fixed_time.strftime('%Y-%m-%d %H:%M:%S %z')}" }

    before do
      create_list :application_digest, 4
    end

    it 'loads all the digest records' do
      travel_to fixed_time do
        expect(GoogleDrive::Session).to receive(:from_service_account_key).and_return(google_session)
        expect(google_session).to receive(:spreadsheet_by_key).and_return(spreadsheet).exactly(2)
        expect(spreadsheet).to receive(:worksheets).and_return([worksheet]).at_least(2)
        expect(worksheet).to receive(:max_rows).and_return(10)
        expect(worksheet).to receive(:delete_rows).with(1, 9)
        expect(worksheet).to receive(:save).exactly(3).times
        expect(worksheet).to receive(:update_cells).with(1, 1, [column_headings])
        expect(worksheet).to receive(:insert_rows).exactly(4).times

        described_class.call
      end
    end
  end
end
