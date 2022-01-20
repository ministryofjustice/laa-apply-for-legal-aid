require 'rails_helper'

RSpec.describe ReportsUploaderJob, type: :job do
  let(:report_uploader) { described_class.new }
  let(:admin_report) { AdminReport.first }
  subject { report_uploader.perform }

  describe '#perform' do
    before do
      allow_any_instance_of(Reports::MIS::ApplicationDetailsReport).to receive(:run).and_return('csv string, application details')
    end

    it 'creates an admin report' do
      expect { subject }.to change { AdminReport.count }.by(1)
    end

    it 'attaches application_details report to admin report' do
      subject
      expect(admin_report.application_details_report).to be_a_kind_of(ActiveStorage::Attached::One)
    end

    context 'when submitted applications report is attached' do
      it 'attaches the correct csv string to admin report' do
        subject
        blob = admin_report.application_details_report.attachment
        expect(blob.download).to eq 'csv string, application details'
      end
    end
  end
end
