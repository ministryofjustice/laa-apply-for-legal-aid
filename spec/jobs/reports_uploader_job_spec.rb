require "rails_helper"

RSpec.describe ReportsUploaderJob do
  let(:report_uploader) { described_class.new }

  describe "#expiration" do
    it "returns 24 hours in seconds" do
      expect(report_uploader.expiration).to eq 86_400
    end
  end

  describe "#perform" do
    before { allow(Reports::MIS::ApplicationDetailsReport).to receive(:new).and_return(mock_report_generator) }

    let(:mock_report_generator) { instance_double Reports::MIS::ApplicationDetailsReport, run: tempfile_name }
    let(:admin_report) { AdminReport.first }
    let(:generated_file_contents) { "aaa,bbb,ccc\nddd,eee,fff" }
    let(:tempfile_name) do
      filename = Rails.root.join("tmp/my_temp_file.csv")
      File.open(filename, "w") { |fp| fp.puts generated_file_contents }
      filename
    end

    context "when AdminReport record does not exist" do
      before { AdminReport.delete_all }

      it "creates an admin report" do
        expect { report_uploader.perform }.to change(AdminReport, :count).by(1)
      end

      it "attaches generated file to admin report" do
        report_uploader.perform
        expect(admin_report.reload.application_details_report).to be_a_kind_of(ActiveStorage::Attached::One)
      end

      context "when submitted applications report is attached" do
        it "attaches the contents of the generated file to the admin report" do
          report_uploader.perform
          blob = admin_report.application_details_report.attachment
          expect(blob.download.chomp).to eq generated_file_contents
        end
      end
    end

    context "when AdminReport record already exists" do
      before { create(:admin_report, :with_reports_attached) }

      it "does not create another record" do
        expect { report_uploader.perform }.not_to change(AdminReport, :count)
      end

      it "updates the existing record" do
        original_updated_time = AdminReport.first.updated_at
        report_uploader.perform
        expect(AdminReport.first.updated_at > original_updated_time).to be true
      end
    end
  end
end
