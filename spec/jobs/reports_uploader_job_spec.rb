require "rails_helper"

RSpec.describe ReportsUploaderJob, type: :job do
  subject { report_uploader.perform }
  let(:report_uploader) { described_class.new }

  describe "#expiration" do
    subject(:expiration) { report_uploader.expiration }
    it "returns 24 hours in seconds" do
      expect(expiration).to eq 86_400
    end
  end

  describe "#perform" do
    before do
      allow_any_instance_of(Reports::MIS::ApplicationDetailsReport).to receive(:run).and_return("csv string, application details")
    end

    context "AdminReport record does not exist" do
      let(:admin_report) { AdminReport.first }

      it "creates an admin report" do
        expect { subject }.to change(AdminReport, :count).by(1)
      end

      it "attaches application_details report to admin report" do
        subject
        expect(admin_report.reload.application_details_report).to be_a_kind_of(ActiveStorage::Attached::One)
      end

      context "when submitted applications report is attached" do
        it "attaches the correct csv string to admin report" do
          subject
          blob = admin_report.application_details_report.attachment
          expect(blob.download).to eq "csv string, application details"
        end
      end
    end

    context "AdminReport record already exists" do
      before do
        # create an AdminReport record with the correct attachments
        report_uploader.perform
      end

      it "does not create another record" do
        subject
        expect { subject }.not_to change(AdminReport, :count)
      end

      it "updates the existing record" do
        original_updated_time = AdminReport.first.updated_at
        subject
        expect(AdminReport.first.updated_at > original_updated_time).to be true
      end
    end
  end
end
