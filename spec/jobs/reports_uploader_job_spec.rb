require 'rails_helper'

RSpec.describe ReportsUploaderJob, type: :job do
  let(:report_uploader) { described_class.new }
  let(:admin_report) { AdminReport.first }
  subject { report_uploader.perform }

  describe '#perform' do
    before do
      allow_any_instance_of(Reports::MIS::ApplicationDetailsReport).to receive(:run).and_return('csv string, submitted applications')
      allow_any_instance_of(Reports::MIS::NonPassportedApplicationsReport).to receive(:run).and_return('csv string, nonpassported')
    end

    it 'creates an admin report' do
      expect { subject }.to change { AdminReport.count }.by(1)
    end

    it 'attaches submitted applications report to admin report' do
      subject
      expect(admin_report.submitted_applications).to be_a_kind_of(ActiveStorage::Attached::One)
    end

    it 'attaches nonpassported applications report to admin report' do
      subject
      expect(admin_report.non_passported_applications).to be_a_kind_of(ActiveStorage::Attached::One)
    end

    context 'when non passported applications report is attached' do
      it 'attaches the correct csv string to admin report' do
        subject
        blob = admin_report.non_passported_applications.attachment
        expect(blob.download).to eq 'csv string, nonpassported'
      end
    end
    context 'when submitted applications report is attached' do
      it 'attaches the correct csv string to admin report' do
        subject
        blob = admin_report.submitted_applications.attachment
        expect(blob.download).to eq 'csv string, submitted applications'
      end
    end
  end
end
